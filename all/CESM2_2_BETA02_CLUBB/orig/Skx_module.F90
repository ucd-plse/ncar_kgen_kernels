!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-20 14:46:37 
!KGEN version : 0.8.1 
  
!-------------------------------------------------------------------------
!$Id: Skx_module.F90 91094 2019-04-29 22:53:19Z cacraig@ucar.edu $
!===============================================================================


module Skx_module
    USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

    IMPLICIT NONE 

    PRIVATE 

    PUBLIC skx_func, lg_2005_ansatz, xp3_lg_2005_ansatz 

  contains
  !-----------------------------------------------------------------------------

  elemental function Skx_func( xp2, xp3, x_tol )  &
  result( Skx )
    ! Description:
    ! Calculate the skewness of x
    ! References:
    ! None
    !-----------------------------------------------------------------------


      USE constants_clubb, ONLY: three_halves 

      USE parameters_tunable, ONLY: skw_denom_coef, skw_max_mag 

      USE clubb_precision, ONLY: core_rknd 

    implicit none
    ! External

    intrinsic :: min, max
    ! Parameter Constants
    ! Whether to apply clipping to the final result

    logical, parameter ::  & 
      l_clipping_kluge = .false.
    ! Input Variables

    real( kind = core_rknd ), intent(in) :: & 
      xp2,   & ! <x'^2>               [(x units)^2]
      xp3,   & ! <x'^3>               [(x units)^3]
      x_tol    ! x tolerance value    [(x units)]
    ! Output Variable

    real( kind = core_rknd ) :: & 
      Skx      ! Skewness of x        [-]
    ! ---- Begin Code ----
    !Skx = xp3 / ( max( xp2, x_tol**two ) )**three_halves
    ! Calculation of skewness to help reduce the sensitivity of this value to
    ! small values of xp2.


    Skx = xp3 / ( xp2 + Skw_denom_coef * x_tol**2 )**three_halves
    ! This is no longer needed since clipping is already
    ! imposed on wp2 and wp3 elsewhere in the code
    ! I turned clipping on in this local copy since thlp3 and rtp3 are not clipped


    if ( l_clipping_kluge ) then
      Skx = min( max( Skx, -Skw_max_mag ), Skw_max_mag )
    end if

    return

  end function Skx_func
  !-----------------------------------------------------------------------------

  elemental function LG_2005_ansatz( Skw, wpxp, wp2, &
                                     xp2, beta, sigma_sqd_w, x_tol ) &
  result( Skx )
    ! Description:
    ! Calculate the skewness of x using the diagnostic ansatz of Larson and
    ! Golaz (2005).
    ! References:
    ! Vincent E. Larson and Jean-Christophe Golaz, 2005:  Using Probability
    ! Density Functions to Derive Consistent Closure Relationships among
    ! Higher-Order Moments.  Mon. Wea. Rev., 133, 1023–1042.
    !-----------------------------------------------------------------------


      USE constants_clubb, ONLY: three_halves, one, w_tol_sqd 

      USE clubb_precision, ONLY: core_rknd 

    implicit none
    ! External

    intrinsic :: sqrt
    ! Input Variables

    real( kind = core_rknd ), intent(in) :: &
      Skw,         & ! Skewness of w                  [-]
      wpxp,        & ! Turbulent flux of x            [m/s (x units)]
      wp2,         & ! Variance of w                  [m^2/s^2]
      xp2,         & ! Variance of x                  [(x units)^2]
      beta,        & ! Tunable parameter              [-]
      sigma_sqd_w, & ! Normalized variance of w       [-]
      x_tol          ! Minimum tolerance of x         [(x units)]
    ! Output Variable

    real( kind = core_rknd ) :: &
      Skx            ! Skewness of x                  [-]
    ! Local Variables

    real( kind = core_rknd ) :: &
      nrmlzd_corr_wx, & ! Normalized correlation of w and x       [-]
      nrmlzd_Skw        ! Normalized skewness of w                [-]
    ! ---- Begin Code ----
    ! weberjk, 8-July 2015. Commented this out for now. cgils was failing during some tests.
    ! Larson and Golaz (2005) eq. 16


    nrmlzd_corr_wx &
    = ( wpxp / ( sqrt( max( wp2, w_tol_sqd ) ) &
                 * sqrt( max( xp2, x_tol**2 ) ) ) ) &
      / sqrt( one - sigma_sqd_w )
    ! Larson and Golaz (2005) eq. 11

    nrmlzd_Skw = Skw * ( one - sigma_sqd_w)**(-three_halves)
    ! Larson and Golaz (2005) eq. 33

    Skx = nrmlzd_Skw * nrmlzd_corr_wx &
          * ( beta + ( one - beta ) * nrmlzd_corr_wx**2 )


    return

  end function LG_2005_ansatz
  !-----------------------------------------------------------------------------

  function xp3_LG_2005_ansatz( Skw_zt, wpxp_zt, wp2_zt, &
                               xp2_zt, sigma_sqd_w_zt, x_tol ) &
  result( xp3 )
    ! Description:
    ! Calculate <x'^3> after calculating the skewness of x using the ansatz of
    ! Larson and Golaz (2005).
    ! References:
    !-----------------------------------------------------------------------


      USE grid_class, ONLY: gr 

      USE constants_clubb, ONLY: three_halves 

      USE parameters_tunable, ONLY: beta, skw_denom_coef 

      USE clubb_precision, ONLY: core_rknd 

    implicit none
    ! External

    intrinsic :: sqrt
    ! Input Variables

    real( kind = core_rknd ), dimension(gr%nz), intent(in) :: &
      Skw_zt,         & ! Skewness of w on thermodynamic levels   [-]
      wpxp_zt,        & ! Flux of x  (interp. to t-levs.)         [m/s(x units)]
      wp2_zt,         & ! Variance of w (interp. to t-levs.)      [m^2/s^2]
      xp2_zt,         & ! Variance of x (interp. to t-levs.)      [(x units)^2]
      sigma_sqd_w_zt    ! Normalized variance of w (interp. to t-levs.)   [-]

    real( kind = core_rknd ), intent(in) :: &
      x_tol    ! Minimum tolerance of x         [(x units)]
    ! Return Variable

    real( kind = core_rknd ), dimension(gr%nz) :: &
      xp3    ! <x'^3> (thermodynamic levels)    [(x units)^3]
    ! Local Variable

    real( kind = core_rknd ), dimension(gr%nz) :: &
      Skx_zt    ! Skewness of x on thermodynamic levels    [-]
    ! Calculate skewness of x using the ansatz of LG05.


    Skx_zt(1:gr%nz) &
    = LG_2005_ansatz( Skw_zt(1:gr%nz), wpxp_zt(1:gr%nz), wp2_zt(1:gr%nz), &
                      xp2_zt(1:gr%nz), beta, sigma_sqd_w_zt(1:gr%nz), x_tol )
    ! Calculate <x'^3> using the reverse of the special sensitivity reduction
    ! formula in function Skx_func above.

    xp3 = Skx_zt * ( xp2_zt + Skw_denom_coef * x_tol**2 )**three_halves


    return

  end function xp3_LG_2005_ansatz
  !-----------------------------------------------------------------------------


end module Skx_module