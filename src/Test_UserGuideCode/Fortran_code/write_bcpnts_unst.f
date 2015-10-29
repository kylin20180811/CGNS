      program write_bcpnts_unst
      use cgns
c
c   Opens an existing CGNS file that contains a simple 3-D 
c   unstructured grid, and adds BC definitions (defined
c   as individual FaceCenter "points" = PointList+GridLocation=FaceCenter)
c   The BCs are added as FaceCenter points, associated with
c   face elements (QUAD_4), rather than associated to nodes
c
c   For the following, be sure you are using Version 2.0 or 
c   later release of the API
c
c   The CGNS grid file 'grid.cgns' must already exist
c   (created using write_grid_unst.f).  Note: whether the 
c   existing CGNS file has a flow solution in it already or
c   not is irrelevant.
c
c   This program uses the fortran convention that all
c   variables beginning with the letters i-n are integers,
c   by default, and all others are real
c
c   Example compilation for this program is (change paths!):
c   Note: when using the cgns module file, you must use the SAME fortran compiler 
c   used to compile CGNS (see make.defs file)
c   ...or change, for example, via environment "setenv FC ifort"
c
c   ifort -I ../../../CGNS_github/CGNS/src -c write_bcpnts_unst.f
c   ifort -o write_bcpnts_unst write_bcpnts_unst.o -L ../../../CGNS_github/CGNS/src/lib -lcgns
c
c   (../../../CGNS_github/CGNS/src/lib is the location where the compiled
c   library libcgns.a is located)
c
c   The following is no longer supported; now superceded by "use cgns":
c     include 'cgnslib_f.h'
c   Note Windows machines need to include cgnswin_f.h
c
      parameter (maxcount=960)
      integer(cgsize_t) ipnts(maxcount),icounts
c
c  WRITE BOUNDARY CONDITIONS TO EXISTING CGNS FILE
c  open CGNS file for modify
      call cg_open_f('grid.cgns',CG_MODE_MODIFY,index_file,ier)
      if (ier .ne. CG_OK) call cg_error_exit_f
c  we know there is only one base (real working code would check!)
      index_base=1
c  we know there is only one zone (real working code would check!)
      index_zone=1
c  we know that for the unstructured zone, the following face elements
c  have been defined as inflow (real working code would check!):
      nelem_start=2561
      nelem_end=2688
      icount=0
      do n=nelem_start,nelem_end
        icount=icount+1
        ipnts(icount)=n
      enddo
      if (icount .gt. maxcount) then
        write(6,'('' Error.  Need to increase maxcount to at least'',
     +   i5)') icount
        stop
      end if
c  write boundary conditions for ilo face
      icounts=icount
      call cg_boco_write_f(index_file,index_base,index_zone,'Ilo',
     + BCTunnelInflow,PointList,icounts,ipnts,index_bc,ier)
c  we know that for the unstructured zone, the following face elements
c  have been defined as outflow (real working code would check!):
      nelem_start=2689
      nelem_end=2816
      icount=0
      do n=nelem_start,nelem_end
        icount=icount+1
        ipnts(icount)=n
      enddo
      if (icount .gt. maxcount) then
        write(6,'('' Error.  Need to increase maxcount to at least'',
     +   i5)') icount
        stop
      end if
c  write boundary conditions for ihi face
      icounts=icount
      call cg_boco_write_f(index_file,index_base,index_zone,'Ihi',
     + BCExtrapolate,PointList,icounts,ipnts,index_bc,ier)
c  we know that for the unstructured zone, the following face elements
c  have been defined as walls (real working code would check!):
      nelem_start=2817
      nelem_end=3776
      icount=0
      do n=nelem_start,nelem_end
        icount=icount+1
        ipnts(icount)=n
      enddo
      if (icount .gt. maxcount) then
        write(6,'('' Error.  Need to increase maxcount to at least'',
     +   i5)') icount
        stop
      end if
c  write boundary conditions for wall faces
      icounts=icount
      call cg_boco_write_f(index_file,index_base,index_zone,'Walls',
     + BCWallInviscid,PointList,icounts,ipnts,index_bc,ier)
c
c  the above are all face-center locations for the BCs - must indicate this,
c  otherwise Vertices will be assumed!
      do ibc=1,index_bc
c  (the following call positions you in BC_t - it assumes there
c  is only one Zone_t and one ZoneBC_t - real working code would check!)
        call cg_goto_f(index_file,index_base,ier,'Zone_t',1,
     +    'ZoneBC_t',1,'BC_t',ibc,'end')
        call cg_gridlocation_write_f(FaceCenter,ier)
      enddo
c  close CGNS file
      call cg_close_f(index_file,ier)
      write(6,'('' Successfully added FaceCenter BCs (PointList) to'',
     +  '' unstructured grid file grid.cgns'')')
      stop
      end
