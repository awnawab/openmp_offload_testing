program test_openmp_target_present
!... Test the equivalent of the OpenACC present clause
   
    implicit none

    integer :: a(32)

    a = 1
    !$omp target enter data map(to:a)

    !$omp target data use_device_addr(a)
    !$omp target
    a = a + 2
    !$omp end target
    !$omp end target data

    !$omp target exit data map(from:a)

    if (.not. all(a == 3)) error stop

end program test_openmp_target_present
