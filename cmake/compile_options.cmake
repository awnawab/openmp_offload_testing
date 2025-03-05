set( OpenMP_Fortran_FLAGS   "-mp=gpu -mp=bind,allcores,numa  -gpu=cc80 -Minfo=mp" CACHE STRING "" )
set( CMAKE_Fortran_FLAGS "-O2 -gopt -fpic" )
