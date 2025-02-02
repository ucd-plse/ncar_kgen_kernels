    !KGEN-generated Fortran source file 
      
    !Generated at : 2021-06-24 13:54:09 
    !KGEN version : 0.9.0 
      
    PROGRAM kernel_driver 
        USE kgen_utils_mod, ONLY: kgen_get_newunit, kgen_error_stop, kgen_dp, kgen_array_sumcheck, kgen_rankthreadinvoke 
        USE micro_mg_cam, ONLY: micro_mg_cam_tend_pack 
          
        USE micro_mg_cam, ONLY: kr_externs_in_micro_mg_cam 
        USE shr_kind_mod, ONLY: r8 => shr_kind_r8 
        USE micro_mg3_0, ONLY: kr_externs_in_micro_mg3_0 
        USE micro_mg_utils, ONLY: kr_externs_in_micro_mg_utils 
        USE wv_sat_methods, ONLY: kr_externs_in_wv_sat_methods 
#if defined(__OPENACC__)
        USE openacc
#endif
        IMPLICIT NONE 
    
#ifdef _MPI
        include 'mpif.h'
#endif
      
        LOGICAL :: kgen_isverified 
        INTEGER :: kgen_ierr_list, kgen_unit_list 
        INTEGER :: kgen_ierr, kgen_unit, kgen_case_count, kgen_count_verified 
        CHARACTER(LEN=1024) :: kgen_filepath 
        REAL(KIND=kgen_dp) :: kgen_measure, kgen_total_time, kgen_min_time, kgen_max_time, kgen_avg_time, kgen_avg_rate
        REAL(KIND=8) :: kgen_array_sum 
        INTEGER :: kgen_mpirank, kgen_openmptid, kgen_kernelinvoke 
        INTEGER :: total_columns, avg_columns
        INTEGER :: myrank, mpisize, info
        LOGICAL :: kgen_evalstage, kgen_warmupstage, kgen_mainstage 
        COMMON / kgen_state / kgen_mpirank, kgen_openmptid, kgen_kernelinvoke, kgen_evalstage, kgen_warmupstage, kgen_mainstage 
          
        REAL(KIND=r8) :: dtime 
        INTEGER :: nlev 
        INTEGER :: mgncol 

#ifdef _MPI
        call mpi_init(info)
        call mpi_comm_rank(mpi_comm_world, myrank, info)
        call mpi_comm_size(mpi_comm_world, mpisize, info)
#else
        myrank=0
        mpisize=1
#endif

        kgen_total_time = 0.0_kgen_dp 
        kgen_min_time = HUGE(0.0_kgen_dp) 
        kgen_max_time = 0.0_kgen_dp 
        kgen_case_count = 0 
        kgen_count_verified = 0           
        total_columns = 0

        kgen_unit_list = kgen_get_newunit() 
!        OPEN (UNIT=kgen_unit_list, FILE="kgen_statefile.lst", STATUS="OLD", IOSTAT=kgen_ierr_list) 
        OPEN (UNIT=kgen_unit_list, FILE=STATEFILE, STATUS="OLD",IOSTAT=kgen_ierr_list)

        IF (kgen_ierr_list .NE. 0) THEN 
            CALL SYSTEM("ls -1 mg3_tend.*.*.* > kgen_statefile.lst") 
            CALL SLEEP(1) 
            kgen_unit_list = kgen_get_newunit() 
            OPEN (UNIT=kgen_unit_list, FILE="kgen_statefile.lst", STATUS="OLD", IOSTAT=kgen_ierr_list) 
        END IF   
        IF (kgen_ierr_list .NE. 0) THEN 
            IF (myrank == 0) THEN 
                WRITE (*, *) "" 
                WRITE (*, *) "ERROR: ""kgen_statefile.lst"" is not found in current directory." 
            END IF   
            STOP 
        END IF   
        DO WHILE ( kgen_ierr_list .EQ. 0 ) 
            READ (UNIT = kgen_unit_list, FMT="(A)", IOSTAT=kgen_ierr_list) kgen_filepath 
            IF (kgen_ierr_list .EQ. 0) THEN 
                kgen_unit = kgen_get_newunit() 
                CALL kgen_rankthreadinvoke(TRIM(ADJUSTL(kgen_filepath)), kgen_mpirank, kgen_openmptid, kgen_kernelinvoke) 
                OPEN (UNIT=kgen_unit, FILE=TRIM(ADJUSTL(kgen_filepath)), STATUS="OLD", ACCESS="STREAM", FORM="UNFORMATTED", &
                &ACTION="READ", CONVERT="BIG_ENDIAN", IOSTAT=kgen_ierr) 
                IF (kgen_ierr == 0) THEN 
                    IF (myrank == 0) THEN 
                        WRITE (*, *) "" 
                        WRITE (*, *) "***************** Verification against '" // trim(adjustl(kgen_filepath)) // "' &
                        &*****************" 
                    END IF   
                    kgen_evalstage = .TRUE. 
                    kgen_warmupstage = .FALSE. 
                    kgen_mainstage = .FALSE. 
                      
                      
                    !driver read in arguments 
                    READ (UNIT = kgen_unit) dtime 
                    READ (UNIT = kgen_unit) nlev 
                    READ (UNIT = kgen_unit) mgncol 
                      
                    !extern input variables 
                    CALL kr_externs_in_micro_mg_cam(kgen_unit) 
                    CALL kr_externs_in_micro_mg3_0(kgen_unit) 
                    CALL kr_externs_in_micro_mg_utils(kgen_unit) 
                    CALL kr_externs_in_wv_sat_methods(kgen_unit) 
                      
                    !callsite part 
                    CALL micro_mg_cam_tend_pack(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, dtime, nlev, mgncol) 
                    REWIND (UNIT=kgen_unit) 
                    kgen_evalstage = .FALSE. 
                    kgen_warmupstage = .TRUE. 
                    kgen_mainstage = .FALSE. 
                      
                      
                    !driver read in arguments 
                    READ (UNIT = kgen_unit) dtime 
                    READ (UNIT = kgen_unit) nlev 
                    READ (UNIT = kgen_unit) mgncol 
                      
                    !extern input variables 
                    CALL kr_externs_in_micro_mg_cam(kgen_unit) 
                    CALL kr_externs_in_micro_mg3_0(kgen_unit) 
                    CALL kr_externs_in_micro_mg_utils(kgen_unit) 
                    CALL kr_externs_in_wv_sat_methods(kgen_unit) 
                      
                    !callsite part 
                    CALL micro_mg_cam_tend_pack(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, dtime, nlev, mgncol) 
                    REWIND (UNIT=kgen_unit) 
                    kgen_evalstage = .FALSE. 
                    kgen_warmupstage = .FALSE. 
                    kgen_mainstage = .TRUE. 
                    kgen_case_count = kgen_case_count + 1 
                    kgen_isverified = .FALSE. 
                      
                      
                    !driver read in arguments 
                    READ (UNIT = kgen_unit) dtime 
                    READ (UNIT = kgen_unit) nlev 
                    READ (UNIT = kgen_unit) mgncol 
                      
                    !extern input variables 
                    CALL kr_externs_in_micro_mg_cam(kgen_unit) 
                    CALL kr_externs_in_micro_mg3_0(kgen_unit) 
                    CALL kr_externs_in_micro_mg_utils(kgen_unit) 
                    CALL kr_externs_in_wv_sat_methods(kgen_unit) 
                      
                    !callsite part 
                    CALL micro_mg_cam_tend_pack(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, dtime, nlev, mgncol) 
                    kgen_total_time = kgen_total_time + kgen_measure 
                    total_columns = total_columns + DFACT*mgncol
                    kgen_min_time = MIN( kgen_min_time, kgen_measure ) 
                    kgen_max_time = MAX( kgen_max_time, kgen_measure ) 
                    IF (kgen_isverified) THEN 
                        kgen_count_verified = kgen_count_verified + 1 
                    END IF   
                END IF   
                CLOSE (UNIT=kgen_unit) 
            END IF   
        END DO   
          
        CLOSE (UNIT=kgen_unit_list) 
          
        IF (myrank == 0) THEN 
            WRITE (*, *) "" 
            WRITE (*, "(A)") "****************************************************" 
            WRITE (*, "(4X,A)") "kernel execution summary: mg3_tend" 
            WRITE (*, "(A)") "****************************************************" 
            print *, 'total_columns: ', total_columns
            avg_columns   = NINT(total_columns / DBLE(kgen_case_count))
            kgen_avg_time = kgen_total_time / DBLE(kgen_case_count)
            kgen_avg_rate = 1.0e6*real(mpisize,kind=kgen_dp)*real(avg_columns,kind=kgen_dp)/kgen_avg_time

            IF (kgen_case_count == 0) THEN 
                WRITE (*, *) "No data file is verified." 
            ELSE 
                WRITE (*, "(4X, A36, A1, I6)") "Total number of verification cases   ", ":", kgen_case_count 
                WRITE (*, "(4X, A36, A1, I6)") "Number of verification-passed cases ", ":", kgen_count_verified 
                WRITE (*, *) "" 
                IF (real(kgen_count_verified,kind=r8)/real(kgen_case_count,kind=r8) > 0.5_r8) THEN 
                    WRITE (*, "(4X,A)") "kernel: mg3_tend: PASSED verification" 
                ELSE 
                    WRITE (*, "(4X,A)") "kernel: mg3_tend: FAILED verification" 
                END IF   
                WRITE (*, *) "" 
                WRITE (*, "(4X,A19,I3)") "number of processes: ", mpisize 
                WRITE (*, *) "" 
                WRITE (*, "(4X, A, E10.3)") "Average call time (usec): ", kgen_total_time / DBLE(kgen_case_count) 
                WRITE (*, "(4X, A, E10.3)") "Minimum call time (usec): ", kgen_min_time 
                WRITE (*, "(4X, A, E10.3)") "Maximum call time (usec): ", kgen_max_time 
                WRITE (*, *) ""
                WRITE (*, "(4X,A19,I6)") "number of columns: ",avg_columns
                WRITE (*, "(4X, A, F12.2)") "Average columns per sec : ", kgen_avg_rate
            END IF   
            WRITE (*, "(A)") "****************************************************" 
        END IF
#ifdef _MPI
        call MPI_finalize(info)
#endif 
    END PROGRAM   
    BLOCK DATA KGEN 
        INTEGER :: kgen_mpirank = 0, kgen_openmptid = 0, kgen_kernelinvoke = 0 
        LOGICAL :: kgen_evalstage = .TRUE., kgen_warmupstage = .FALSE., kgen_mainstage = .FALSE. 
        COMMON / kgen_state / kgen_mpirank, kgen_openmptid, kgen_kernelinvoke, kgen_evalstage, kgen_warmupstage, kgen_mainstage 
    END BLOCK DATA KGEN 
