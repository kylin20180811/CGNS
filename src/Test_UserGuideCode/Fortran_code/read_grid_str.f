      program read_grid_str
      use cgns
c
c   Reads simple 3-D structured grid from CGNS file
c   (companion program to write_grid_str.f)
c
c   The CGNS grid file 'grid.cgns' must already exist.
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
c   ifort -I ../../../CGNS_github/CGNS/src -c read_grid_str.f
c   ifort -o read_grid_str read_grid_str.o -L ../../../CGNS_github/CGNS/src/lib -lcgns
c
c   (../../../CGNS_github/CGNS/src/lib is the location where the compiled
c   library libcgns.a is located)
c
c   The following is no longer supported; now superceded by "use cgns":
c     include 'cgnslib_f.h'
c   Note Windows machines need to include cgnswin_f.h
c
c   dimension statements (note that tri-dimensional arrays
c   x,y,z must be dimensioned exactly as (21,17,N) (N>=9) 
c   for this particular case or else they will be read from
c   the CGNS file incorrectly!  Other options are to use 1-D 
c   arrays, use dynamic memory, or pass index values to a 
c   subroutine and dimension exactly there):
      dimension x(21,17,9),y(21,17,9),z(21,17,9)
      integer(cgsize_t) isize(3,3),irmin(3),irmax(3)
      character zonename*32
c
c   READ X, Y, Z GRID POINTS FROM CGNS FILE
c   open CGNS file for read-only
      call cg_open_f('grid.cgns',CG_MODE_READ,index_file,ier)
      if (ier .ne. CG_OK) call cg_error_exit_f
c   we know there is only one base (real working code would check!)
      index_base=1
c   we know there is only one zone (real working code would check!)
      index_zone=1
c   get zone size (and name - although not needed here)
      call cg_zone_read_f(index_file,index_base,index_zone,zonename,
     + isize,ier)
c   lower range index
      irmin(1)=1
      irmin(2)=1
      irmin(3)=1
c   upper range index of vertices
      irmax(1)=isize(1,1)
      irmax(2)=isize(2,1)
      irmax(3)=isize(3,1)
c   read grid coordinates
      call cg_coord_read_f(index_file,index_base,index_zone,
     + 'CoordinateX',RealSingle,irmin,irmax,x,ier)
      call cg_coord_read_f(index_file,index_base,index_zone,
     + 'CoordinateY',RealSingle,irmin,irmax,y,ier)
      call cg_coord_read_f(index_file,index_base,index_zone,
     + 'CoordinateZ',RealSingle,irmin,irmax,z,ier)
c   close CGNS file
      call cg_close_f(index_file,ier)
      write(6,'('' Successfully read grid from file grid.cgns'')')
      write(6,'(''   For example, x,y,z(21,17,9)='',3f12.5)')
     + x(21,17,9),y(21,17,9),z(21,17,9)
      write(6,'('' Program successful... ending now'')')
      stop
      end
