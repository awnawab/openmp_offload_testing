program test_openmp_target_struct
   
    use omp_lib
    use, intrinsic :: iso_c_binding
    implicit none

    type ptr_struct
       integer, pointer, contiguous :: ptr(:) => null()
    end type ptr_struct

    type(ptr_struct) :: p

    integer, pointer :: a(:) => null()
    integer, pointer, contiguous :: a_dev(:) => null()
    integer(kind=c_int) :: err, hst_id, dev_id
    integer(kind=c_size_t) :: siz, offset
    type(c_ptr) :: a_dev_ptr = c_null_ptr


    allocate(a(256))
    allocate(a_dev(256))

    a = 1

    siz = sizeof(a)
    offset = 0

    dev_id = omp_get_default_device()
    hst_id = omp_get_initial_device()

    !... allocate device memory
    !$omp target enter data map(alloc:a_dev)

    !$omp target data use_device_ptr(a_dev)
    err = omp_target_memcpy(c_loc(a_dev), c_loc(a), siz, offset, offset, dev_id, hst_id)
    !$omp end target data

    !$omp target enter data map(to:p)
    p%ptr => a_dev
    !$omp target enter data map(to:p%ptr)

    !$omp target map(to:p)
    p%ptr = p%ptr + 2
    !$omp end target

    !$omp target data use_device_ptr(a_dev)
    err = omp_target_memcpy(c_loc(a), c_loc(a_dev), siz, offset, offset, hst_id, dev_id)
    !$omp end target data

    !$omp target exit data map(release: p%ptr) map(delete:p,a_dev)

    if (.not. all(a == 3)) error stop
    deallocate(a)
    deallocate(a_dev)

end program test_openmp_target_struct
