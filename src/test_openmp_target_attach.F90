program test_openmp_target_attach
!... Test implicit pointer attachment
   
    implicit none

    integer, pointer, contiguous :: p(:) => null()
    integer, pointer, contiguous :: a(:) => null()

    allocate(a(256))

    a = 1

    !... allocate device memory
    !$omp target enter data map(to:a)

    p => a
    !$omp target
       p = p + 2
    !$omp end target

    !$omp target exit data map(from:a)

    if (.not. all(a == 3)) error stop
    deallocate(a)

end program test_openmp_target_attach
