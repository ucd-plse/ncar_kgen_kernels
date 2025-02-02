!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-20 14:46:36 
!KGEN version : 0.8.1 
  
!-----------------------------------------------------------------------
! $Id$
!===============================================================================


module stats_type_utilities
  ! Description:
  !   Contains subroutines for interfacing with type, stats
  !-----------------------------------------------------------------------


    USE stats_type, ONLY: stats 

    USE clubb_precision, ONLY: core_rknd 
    USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 
    USE stats_type, ONLY: kr_stats_type_stats 
    USE stats_type, ONLY: kv_stats_type_stats 

    IMPLICIT NONE 

    PRIVATE 

    PUBLIC stat_update_var, stat_update_var_pt, stat_begin_update, stat_begin_update_pt, stat_end_update, stat_end_update_pt, &
    &stat_modify, stat_modify_pt 
    PUBLIC kr_stats_type_stats 
    PUBLIC kv_stats_type_stats 
  contains
  !=============================================================================


  !=============================================================================

  subroutine stat_update_var( var_index, value, grid_kind )
    ! Description:
    ! This updates the value of a statistics variable located at var_index
    ! associated with grid type 'grid_kind' (zt, zm, or sfc).
    ! This subroutine is used when a statistical variable needs to be updated
    ! only once during a model timestep.
    ! In regards to budget terms, this subroutine is used for variables that
    ! are either completely implicit (e.g. wprtp_ma) or completely explicit
    ! (e.g. wp2_pr3).  For completely implicit terms, once the variable has been
    ! solved for, the implicit contribution can be finalized.  The finalized
    ! implicit contribution is sent into stat_update_var_pt.  For completely
    ! explicit terms, the explicit contribution is sent into stat_update_var_pt
    ! once it has been calculated.
    !---------------------------------------------------------------------

    !
    !

      USE clubb_precision, ONLY: stat_rknd 

      USE stat_file_module, ONLY: clubb_i, clubb_j 

    implicit none
    ! Input Variables(s)


    integer, intent(in) ::  &
      var_index ! The index at which the variable is stored  []
    ! Input/Output Variable(s)

    type(stats), intent(inout) ::  &
      grid_kind ! Which grid the variable is located on (zt, zm, rad, or sfc )
    ! Input Variable(s) NOTE: Due to the implicit none above, these must
    ! be declared below to allow the use of grid_kind


    real( kind = core_rknd ), dimension(grid_kind%kk), intent(in) :: &
      value ! Value of field being added to the statistic    [Units Vary]

    integer :: k

    if ( var_index > 0 ) then
      do k = 1, grid_kind%kk
        grid_kind%accum_field_values(clubb_i,clubb_j,k,var_index) =  &
             grid_kind%accum_field_values(clubb_i,clubb_j,k,var_index) + real( value(k), &
                kind=stat_rknd )
        grid_kind%accum_num_samples(clubb_i,clubb_j,k,var_index) =  &
             grid_kind%accum_num_samples(clubb_i,clubb_j,k,var_index) + 1
      end do
    endif

    return
  end subroutine stat_update_var
  !=============================================================================

  subroutine stat_update_var_pt( var_index, grid_level, value, grid_kind )
    ! Description:
    ! This updates the value of a statistics variable located at var_index
    ! associated with grid type 'grid_kind' at a specific grid_level.
    ! See the description of stat_update_var for more details.
    !---------------------------------------------------------------------

    !

      USE clubb_precision, ONLY: stat_rknd 

      USE stat_file_module, ONLY: clubb_i, clubb_j 

    implicit none
    ! Input Variables(s)


    integer, intent(in) ::  &
      var_index,    & ! The index at which the variable is stored           []
      grid_level      ! The level at which the variable is to be modified   []

    real( kind = core_rknd ), intent(in) :: &
      value ! Value of field being added to the statistic         [Units Vary]
    ! Input/Output Variable(s)

    type(stats), intent(inout) ::  &
      grid_kind ! Which grid the variable is located on (zt, zm, rad, or sfc).

    if ( var_index > 0 ) then

      grid_kind%accum_field_values(clubb_i,clubb_j,grid_level,var_index) = &
        grid_kind%accum_field_values(clubb_i,clubb_j,grid_level,var_index) + &
          real( value, kind=stat_rknd )

      grid_kind%accum_num_samples(clubb_i,clubb_j,grid_level,var_index) = &
        grid_kind%accum_num_samples(clubb_i,clubb_j,grid_level,var_index) + 1

    endif

    return
  end subroutine stat_update_var_pt
  !=============================================================================

  subroutine stat_begin_update( var_index, value, &
                                grid_kind )
    ! Description:
    ! This begins an update of the value of a statistics variable located at
    ! var_index on the (zt, zm, or sfc) grid.  It is used in conjunction with
    ! subroutine stat_end_update.
    ! This subroutine is used when a statistical variable needs to be updated
    ! more than one time during a model timestep.  Commonly, this is used for
    ! beginning a budget term calculation.
    ! In this type of stats calculation, we first subtract the field
    ! (e.g. rtm / dt ) from the statistic, then update rtm by a term
    ! (e.g. clip rtm), and then re-add the field (e.g. rtm / dt) to the
    ! statistic.
    ! Example:
    !  call stat_begin_update( irtm_bt, real(rtm / dt), stats_zt )
    !  !!! Perform clipping of rtm !!!
    !  call stat_end_update( irtm_bt, real(rtm / dt), stats_zt )
    ! This subroutine is often used with stats budget terms for variables that
    ! have both implicit and explicit components (e.g. wp3_ta).  The explicit
    ! component is sent into stat_begin_update_pt (with the sign reversed
    ! because stat_begin_update_pt automatically subtracts the value sent into
    ! it).  Then, once the variable has been solved for, the implicit
    ! statistical contribution can be finalized.  The finalized implicit
    ! component is sent into stat_end_update_pt.
    !---------------------------------------------------------------------

    !
    !
    !
    !
    !
    !
    !

      USE grid_class, ONLY: gr 

    implicit none
    ! Input Variables(s)


    integer, intent(in) ::  &
      var_index      ! The index at which the variable is stored           []

    real( kind = core_rknd ), dimension(gr%nz), intent(in) :: &
      value          ! Value of field being added to the statistic         [Units Vary]
    ! Input/Output Variable(s)

    type(stats), intent(inout) ::  &
      grid_kind ! Which grid the variable is located on (zt, zm, rad, or sfc).

    integer :: i

    do i = 1, gr%nz

      call stat_begin_update_pt &
            ( var_index, i, value(i), grid_kind )

    enddo

    return
  end subroutine stat_begin_update
  !=============================================================================

  subroutine stat_begin_update_pt &
             ( var_index, grid_level, value, grid_kind )
    ! Description:
    !   This begins an update of the value of a statistics variable located at
    !   var_index associated with the grid type (grid_kind) at a specific
    !   grid_level.  It is used in conjunction with subroutine stat_end_update_pt.
    ! Notes:
    !   Commonly this is used for beginning a budget.  See the description of
    !   stat_begin_update for more details.
    ! References:
    !   None
    !---------------------------------------------------------------------

    !
    !

      USE clubb_precision, ONLY: stat_rknd 

      USE stat_file_module, ONLY: clubb_i, clubb_j 

      USE constants_clubb, ONLY: fstderr 

      USE error_code, ONLY: clubb_at_least_debug_level 

    implicit none
    ! Input Variables(s)


    integer, intent(in) ::  &
      var_index,    & ! The index at which the variable is stored           []
      grid_level      ! The level at which the variable is to be modified   []

    real( kind = core_rknd ), intent(in) :: &
      value ! Value of field being added to the statistic                [Units Vary]
    ! Input/Output Variable(s)

    type(stats), intent(inout) ::  &
      grid_kind ! Which grid the variable is located on (zt, zm, rad, or sfc).
    ! ---- Begin Code ----


    if ( var_index > 0 ) then  ! Are we storing this variable?
      ! Can we begin an update?

      if ( .not. grid_kind%l_in_update(clubb_i,clubb_j,grid_level,var_index) ) then

        grid_kind%accum_field_values(clubb_i,clubb_j,grid_level, var_index) =  &
                grid_kind%accum_field_values(clubb_i,clubb_j,grid_level, var_index) - &
                  real( value, kind=stat_rknd )

        grid_kind%l_in_update(clubb_i,clubb_j,grid_level, var_index) = .true.  ! Start Record

      else if ( clubb_at_least_debug_level( 1 ) ) then

            write(fstderr,*) "Beginning an update before finishing previous for variable: "// &
                              trim( grid_kind%file%var(var_index)%name ) 
      endif

    endif

    return
  end subroutine stat_begin_update_pt
  !=============================================================================

  subroutine stat_end_update( var_index, value, grid_kind )
    ! Description:
    ! This ends an update of the value of a statistics variable located at
    ! var_index on the (zt, zm, or sfc) grid.  It is used in conjunction with
    ! subroutine stat_begin_update.
    ! This subroutine is used when a statistical variable needs to be updated
    ! more than one time during a model timestep.  Commonly, this is used for
    ! finishing a budget term calculation.
    ! In this type of stats calculation, we first subtract the field
    ! (e.g. rtm / dt ) from the statistic, then update rtm by a term
    ! (e.g. clip rtm), and then re-add the field (e.g. rtm / dt) to the
    ! statistic.
    ! Example:
    !  call stat_begin_update( irtm_bt, real(rtm / dt), stats_zt )
    !  !!! Perform clipping of rtm !!!
    !  call stat_end_update( irtm_bt, real(rtm / dt), stats_zt )
    ! This subroutine is often used with stats budget terms for variables that
    ! have both implicit and explicit components (e.g. wp3_ta).  The explicit
    ! component is sent into stat_begin_update_pt (with the sign reversed
    ! because stat_begin_update_pt automatically subtracts the value sent into
    ! it).  Then, once the variable has been solved for, the implicit
    ! statistical contribution can be finalized.  The finalized implicit
    ! component is sent into stat_end_update_pt.
    !---------------------------------------------------------------------

    !
    !
    !
    !
    !
    !
    !

      USE grid_class, ONLY: gr 

    implicit none
    ! Input Variables(s)


    integer, intent(in) ::  &
      var_index ! The index at which the variable is stored           []

    real( kind = core_rknd ), dimension(gr%nz), intent(in) :: &
      value ! Value of field being added to the statistic             [Units Vary]
    ! Input/Output Variable(s)

    type(stats), intent(inout) ::  &
      grid_kind ! Which grid the variable is located on (zt, zm, rad, or sfc).

    integer :: k
    ! ---- Begin Code ----


    do k = 1,gr%nz
      call stat_end_update_pt &
               ( var_index, k, value(k), grid_kind )
    enddo

    return
  end subroutine stat_end_update
  !=============================================================================

  subroutine stat_end_update_pt &
                ( var_index, grid_level, value, grid_kind )
    ! Description:
    ! This ends an update of the value of a statistics variable located at
    ! var_index associated with the grid type (grid_kind) at a specific
    ! grid_level.  It is used in conjunction with subroutine
    ! stat_begin_update_pt.
    ! Commonly this is used for finishing a budget.  See the description of
    ! stat_end_update for more details.
    !---------------------------------------------------------------------

    !

      USE stat_file_module, ONLY: clubb_i, clubb_j 

      USE constants_clubb, ONLY: fstderr 

      USE error_code, ONLY: clubb_at_least_debug_level 

    implicit none
    ! Input Variables(s)


    integer, intent(in) ::  &
      var_index,   & ! The index at which the variable is stored           []
      grid_level     ! The level at which the variable is to be modified   []

    real( kind = core_rknd ), intent(in) :: &
      value       ! Value of field being added to the statistic         [Units Vary]
    ! Input/Output Variable(s)

    type(stats), intent(inout) ::  &
      grid_kind ! Which grid the variable is located on (zt, zm, rad, or sfc).
    ! ---- Begin Code ----


    if ( var_index > 0 ) then ! Are we storing this variable?
      ! Can we end an update?

      if ( grid_kind%l_in_update(clubb_i,clubb_j,grid_level,var_index) ) then

        call stat_update_var_pt &
                 ( var_index, grid_level, value, grid_kind )

        grid_kind%l_in_update(clubb_i,clubb_j,grid_level,var_index) = .false. ! End Record

      else if ( clubb_at_least_debug_level( 1 ) ) then

        write(fstderr,*) "Ending before beginning update. For variable "// &
                          grid_kind%file%var(var_index)%name 
      endif

    endif

    return
  end subroutine stat_end_update_pt
  !=============================================================================

  subroutine stat_modify( var_index, value, &
                          grid_kind )
    ! Description:
    ! This modifies the value of a statistics variable located at var_index on
    ! the (zt, zm, or sfc) grid.  It does not increment the sampling count.
    ! This subroutine is normally used when a statistical variable needs to be
    ! updated more than twice during a model timestep.  Commonly, this is used
    ! if a budget term calculation needs an intermediate modification between
    ! stat_begin_update and stat_end_update.
    !---------------------------------------------------------------------

    !

      USE grid_class, ONLY: gr 

    implicit none
    ! Input Variables(s)


    integer, intent(in) ::  &
      var_index ! The index at which the variable is stored           []

    real( kind = core_rknd ), dimension(gr%nz), intent(in) :: &
     value     ! Value of field being added to the statistic         [Units Vary]
    ! Input/Output Variable(s)

    type(stats), intent(inout) ::  &
      grid_kind ! Which grid the variable is located on (zt, zm, rad, or sfc).

    integer :: k
    ! ---- Begin Code ----


    do k = 1, gr%nz

      call stat_modify_pt( var_index, k, value(k), grid_kind )

    enddo

    return
  end subroutine stat_modify
  !=============================================================================

  subroutine stat_modify_pt( var_index, grid_level, value, &
                             grid_kind )
    ! Description:
    ! This modifies the value of a statistics variable located at var_index on
    ! the grid at a specific point. It does not increment the sampling count.
    ! Commonly this is used for intermediate updates to a budget.  See the
    ! description of stat_modify for more details.
    !---------------------------------------------------------------------

    !

      USE clubb_precision, ONLY: stat_rknd 

      USE stat_file_module, ONLY: clubb_i, clubb_j 

    implicit none
    ! Input Variables(s)


    integer, intent(in) ::  &
      var_index ! The index at which the variable is stored            []


    real( kind = core_rknd ), intent(in) :: &
      value      ! Value of field being added to the statistic         [Units Vary]

    integer, intent(in) ::  &
      grid_level ! The level at which the variable is to be modified   []
    ! Input/Output Variable(s)

    type(stats), intent(inout) ::  &
      grid_kind ! Which grid the variable is located on (zt, zm, rad, or sfc).
    ! ---- Begin Code ----


    if ( var_index > 0 ) then

      grid_kind%accum_field_values(clubb_i,clubb_j,grid_level,var_index )  &
         = grid_kind%accum_field_values(clubb_i,clubb_j,grid_level,var_index ) + &
          real( value, kind=stat_rknd )

    end if

    return
  end subroutine stat_modify_pt
!===============================================================================


end module stats_type_utilities