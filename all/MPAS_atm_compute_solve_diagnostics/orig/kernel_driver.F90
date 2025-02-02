
! KGEN-generated Fortran source file
!
! Filename    : kernel_driver.f90
! Generated at: 2015-09-25 10:14:07
! KGEN version: 0.5.0


PROGRAM kernel_driver
    USE atm_time_integration, ONLY : atm_srk3
    USE mpas_kind_types, ONLY: rkind
    USE atm_time_integration, ONLY : kgen_read_externs_atm_time_integration
        USE kgen_utils_mod, ONLY : kgen_dp, check_t, kgen_init_check, kgen_print_check

    IMPLICIT NONE

    include 'mpif.h'


    INTEGER :: kgen_mpi_rank
    CHARACTER(LEN=16) ::kgen_mpi_rank_conv
    INTEGER, DIMENSION(2), PARAMETER :: kgen_mpi_rank_at = (/ 1, 4 /)
    INTEGER :: kgen_ierr, kgen_unit
    INTEGER :: kgen_repeat_counter
    INTEGER :: kgen_counter
    CHARACTER(LEN=16) :: kgen_counter_conv
    INTEGER, DIMENSION(3), PARAMETER :: kgen_counter_at = (/ 1, 10, 5 /)
    CHARACTER(LEN=1024) :: kgen_filepath
    REAL(KIND=rkind) :: dt
    INTEGER :: info,myrank
    
    call mpi_init(info)
    call mpi_comm_rank(mpi_comm_world, myrank, info)


    DO kgen_repeat_counter = 0, 5
        kgen_counter = kgen_counter_at(mod(kgen_repeat_counter, 3)+1)
        WRITE( kgen_counter_conv, * ) kgen_counter
        kgen_mpi_rank = kgen_mpi_rank_at(mod(kgen_repeat_counter, 2)+1)
        WRITE( kgen_mpi_rank_conv, * ) kgen_mpi_rank
#ifdef SINGLE_PRECISION
        kgen_filepath = "../data_r4/atm_compute_solve_diagnostics." // trim(adjustl(kgen_counter_conv)) // "." // trim(adjustl(kgen_mpi_rank_conv))
#else
        kgen_filepath = "../data/atm_compute_solve_diagnostics." // trim(adjustl(kgen_counter_conv)) // "." // trim(adjustl(kgen_mpi_rank_conv))
#endif
        kgen_unit = kgen_get_newunit()
        OPEN (UNIT=kgen_unit, FILE=kgen_filepath, STATUS="OLD", ACCESS="STREAM", FORM="UNFORMATTED", ACTION="READ", IOSTAT=kgen_ierr, CONVERT="BIG_ENDIAN")
        WRITE (*,*)
        IF ( kgen_ierr /= 0 ) THEN
            CALL kgen_error_stop( "FILE OPEN ERROR: " // trim(adjustl(kgen_filepath)) )
        END IF
        WRITE (*,*)
        WRITE (*,*) "** Verification against '" // trim(adjustl(kgen_filepath)) // "' **"

            CALL kgen_read_externs_atm_time_integration(kgen_unit)

            ! driver variables
            READ(UNIT=kgen_unit) dt

            call atm_srk3(dt, myrank, kgen_unit)

            CLOSE (UNIT=kgen_unit)
    END DO

    call mpi_finalize(info)

    CONTAINS

        ! write subroutines
        ! No subroutines
        FUNCTION kgen_get_newunit() RESULT(new_unit)
           INTEGER, PARAMETER :: UNIT_MIN=100, UNIT_MAX=1000000
           LOGICAL :: is_opened
           INTEGER :: nunit, new_unit, counter
        
           new_unit = -1
           DO counter=UNIT_MIN, UNIT_MAX
               inquire(UNIT=counter, OPENED=is_opened)
               IF (.NOT. is_opened) THEN
                   new_unit = counter
                   EXIT
               END IF
           END DO
        END FUNCTION
        
        SUBROUTINE kgen_error_stop( msg )
            IMPLICIT NONE
            CHARACTER(LEN=*), INTENT(IN) :: msg
        
            WRITE (*,*) msg
            STOP 1
        END SUBROUTINE 


    END PROGRAM kernel_driver
