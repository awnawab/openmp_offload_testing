program test_openmp_target_runtime_hipfort
   
    use omp_lib
    use hipfort
    use, intrinsic :: iso_c_binding
    use, intrinsic :: iso_fortran_env, only : int64
    implicit none

    integer, pointer, contiguous :: p(:) => null()
    integer, pointer :: a(:) => null()
    integer, pointer, contiguous :: a_dev(:) => null()
    integer(kind=c_int) :: hst_id, dev_id, err
    integer(kind=c_size_t) :: offset
    integer(kind=int64) :: siz

    allocate(a(256))
    allocate(a_dev(256))

    a = 1

    siz = sizeof(a)
    offset = 0

    dev_id = omp_get_default_device()
    hst_id = omp_get_initial_device()

    !... allocate device memory
    !$omp target enter data map(alloc:a_dev)

    !$omp target data use_device_addr(a_dev)
    err = hipmemcpyhtod(c_loc(a_dev), c_loc(a), siz)
    !$omp end target data

    p => a_dev
    !$omp target map(to:p)
       p = p + 2
    !$omp end target

    !$omp target data use_device_addr(a_dev)
    err = hipmemcpydtoh(c_loc(a), c_loc(a_dev), siz)
    !$omp end target data

    !$omp target exit data map(delete:a_dev)

    if (.not. all(a == 3)) error stop
    deallocate(a)
    deallocate(a_dev)

end program test_openmp_target_runtime_hipfort
