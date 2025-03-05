set( OpenMP_Fortran_FLAGS   "-mp=bind,allcores,numa" CACHE STRING "" )
set( OpenACC_Fortran_FLAGS "-acc=gpu -mp=gpu -gpu=cc80 -Minfo=mp" CACHE STRING "" )
set( CMAKE_Fortran_FLAGS "-O2 -gopt -fpic" )
