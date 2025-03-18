module field_mod

    use omp_lib
    use, intrinsic :: iso_c_binding
    use, intrinsic :: iso_fortran_env, only : int64
    implicit none

    type :: field
       integer, pointer :: a(:) => null()
       integer, pointer, contiguous :: a_dev(:) => null()

       contains

       procedure :: update_device => field_update_device
       procedure :: update_host => field_update_host
    end type field

    type, extends(field) :: field_owner
    end type field_owner

    contains

    subroutine field_update_device(self, ptr)
        class(field) :: self
        integer, pointer, intent(inout) :: ptr(:)
        integer(kind=c_int) :: err, hst_id, dev_id
        integer(kind=c_size_t) :: offset
        integer(kind=int64) :: siz

        siz = sizeof(self%a)
        offset = 0

        dev_id = omp_get_default_device()
        hst_id = omp_get_initial_device()

        ASSOCIATE( a => self%a, a_dev => self%a_dev )
#ifdef __NVCOMPILER
        !$omp target data use_device_ptr(a_dev)
#else
        !$omp target data use_device_addr(a_dev)
#endif
        err = omp_target_memcpy(c_loc(a_dev), c_loc(a), siz, offset, offset, dev_id, hst_id)
        !$omp end target data
        END ASSOCIATE

        ptr => self%a_dev
    end subroutine field_update_device

    subroutine field_update_host(self)
        class(field) :: self
        integer(kind=c_int) :: err, hst_id, dev_id
        integer(kind=c_size_t) :: offset
        integer(kind=int64) :: siz

        siz = sizeof(self%a)
        offset = 0

        dev_id = omp_get_default_device()
        hst_id = omp_get_initial_device()

        ASSOCIATE( a => self%a, a_dev => self%a_dev )
#ifdef __NVCOMPILER
        !$omp target data use_device_ptr(a_dev)
#else
        !$omp target data use_device_addr(a_dev)
#endif
        err = omp_target_memcpy(c_loc(a), c_loc(a_dev), siz, offset, offset, hst_id, dev_id)
        !$omp end target data
        END ASSOCIATE

    end subroutine field_update_host

end module field_mod

program test_openmp_target_runtime
!... Test the equivalent of the OpenACC attach clause
   
    use field_mod, only : field, field_owner
    implicit none

    class(field), allocatable :: fld
    integer, pointer, contiguous :: p(:) => null()

    allocate(field_owner::fld)

    allocate(fld%a(256))
    allocate(fld%a_dev(256))

    fld%a = 1

    !... allocate device memory
    !$omp target enter data map(alloc:fld%a_dev)

    call fld%update_device(p)

    !...puting a target region in the same scope 
    !...as type-bound methods to a polymorphic object
    !...leads to compilation errors
    !$omp target map(to:p)
       p = p + 2
    !$omp end target

    !...moving the same target region to a type-bound
    !...procedure fixes the problem
!    call kernel()

    call fld%update_host()

    !$omp target exit data map(delete:fld%a_dev)

    if (.not. all(fld%a == 3)) error stop
    deallocate(fld%a)
    deallocate(fld%a_dev)

    deallocate(fld)

    contains

    subroutine kernel()
      !$omp target map(to:p)
         p = p + 2
      !$omp end target
    end subroutine kernel

end program test_openmp_target_runtime
