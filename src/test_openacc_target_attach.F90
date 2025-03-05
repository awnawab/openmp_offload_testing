program test_openacc_target_attach
!... Test the equivalent of the OpenACC attach clause
   
    implicit none

    integer, pointer, contiguous :: p(:) => null()
    integer, pointer, contiguous :: a(:) => null()

    allocate(a(256))

    a = 1

    !... allocate device memory
    !$acc enter data copyin(a)

    p => a
    !$acc serial
       p = p + 2
    !$acc end serial

    !$acc exit data copyout(a)    

    if (.not. all(a == 3)) error stop
    deallocate(a)

end program test_openacc_target_attach
