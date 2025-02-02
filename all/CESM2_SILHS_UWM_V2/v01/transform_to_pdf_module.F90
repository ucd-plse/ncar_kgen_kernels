!KGEN-generated Fortran source file 
  
!Generated at : 2019-07-10 08:35:30 
!KGEN version : 0.8.1 
  
!-------------------------------------------------------------------------------
!$Id: transform_to_pdf_module.F90 91096 2019-04-29 22:54:55Z cacraig@ucar.edu $
!===============================================================================


module transform_to_pdf_module
    USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

    IMPLICIT NONE 

    PUBLIC ltqnorm, multiply_cholesky, transform_uniform_sample_to_pdf 

    PRIVATE sample_points, gaus_mixt_points 

    PRIVATE 

  contains
!-------------------------------------------------------------------------------

  subroutine transform_uniform_sample_to_pdf &
             ( pdf_dim, d_uniform_extra, & ! In
               mu1, mu2, sigma1, sigma2, & ! In
               corr_Cholesky_mtx_1, & ! In
               corr_Cholesky_mtx_2, & ! In
               X_u_one_lev, X_mixt_comp_one_lev, & ! In
               cloud_frac_1, cloud_frac_2, & ! In
               l_in_precip_one_lev, & ! In
               X_nl_one_lev ) ! Out
! Description:
!   This subroutine transforms a uniform sample to a sample from CLUBB's PDF.
! References:
!   https://arxiv.org/pdf/1711.03675v1.pdf#nameddest=url:uniform2pdf
!   ``Supplying Local Microphysical Parameterizations with Information about
!     Subgrid Variability: Latin Hypercube Sampling'', JAS Vol. 62,
!     p. 4010--4026, Larson, et al. 2005
!-------------------------------------------------------------------------------

!

      USE array_index, ONLY: iipdf_chi, iipdf_eta, iipdf_w 

      USE matrix_operations, ONLY: row_mult_lower_tri_matrix 

      USE constants_clubb, ONLY: one, zero 

      USE clubb_precision, ONLY: core_rknd 

    implicit none
    ! External

    intrinsic :: max
    ! Input Variables

    integer, intent(in) :: &
      pdf_dim, &  ! `d' Number of variates (normally 3 + microphysics specific variables)
      d_uniform_extra ! Number of variates included in uniform sample only (often 2)

    real( kind = core_rknd ), dimension(pdf_dim,pdf_dim), intent(in) :: &
      corr_Cholesky_mtx_1, & ! Correlations Cholesky matrix (1st comp.)  [-]
      corr_Cholesky_mtx_2    ! Correlations Cholesky matrix (2nd comp.)  [-]

    real( kind = core_rknd ), dimension(pdf_dim), intent(in) :: &
      mu1,    & ! Means of the hydrometeors, 1st comp. (chi, eta, w, <hydrometeors>)  [units vary]
      mu2,    & ! Means of the hydrometeors, 2nd comp. (chi, eta, w, <hydrometeors>)  [units vary]
      sigma1, & ! Stdevs of the hydrometeors, 1st comp. (chi, eta, w, <hydrometeors>) [units vary]
      sigma2    ! Stdevs of the hydrometeors, 2nd comp. (chi, eta, w, <hydrometeors>) [units vary]

    real( kind = core_rknd ), intent(in), dimension(pdf_dim+d_uniform_extra) :: &
      X_u_one_lev ! Sample drawn from uniform distribution from a particular grid level

    integer, intent(in) :: &
      X_mixt_comp_one_lev ! Whether we're in the 1st or 2nd mixture component

    real( kind = core_rknd ), intent(in) :: &
      cloud_frac_1, & ! Cloud fraction (1st PDF component)    [-]
      cloud_frac_2    ! Cloud fraction (2nd PDF component)    [-]

    logical, intent(in) :: &
      l_in_precip_one_lev ! Whether we are in precipitation (T/F)

    real( kind = core_rknd ), intent(out), dimension(pdf_dim) :: &
      X_nl_one_lev ! Sample that is transformed ultimately to normal-lognormal
    ! Local Variables


    logical, dimension(pdf_dim) :: &
      l_d_variable_lognormal ! Whether a given variable in X_nl has a lognormal dist.

    real( kind = core_rknd ), dimension(pdf_dim,pdf_dim) :: &
      Sigma1_Cholesky, Sigma2_Cholesky ! Cholesky factorization of Sigma1,2

    real( kind = core_rknd ), dimension(pdf_dim) :: &
       Sigma1_scaling, & ! Scaling factors for Sigma1 for accuracy [units vary]
       Sigma2_scaling    ! Scaling factors for Sigma2 for accuracy [units vary]

    logical :: &
      l_Sigma1_scaling, l_Sigma2_scaling ! Whether we're scaling Sigma1 or Sigma2

    integer :: i !, ivar1, ivar2
    ! Flag to clip sample point values of chi in extreme situations.

    logical, parameter :: &
      l_clip_extreme_chi_sample_pts = .true.
    ! ---- Begin Code ----
    ! Determine which variables are a lognormal distribution


    i = max( iiPDF_chi, iiPDF_eta, iiPDF_w )
    l_d_variable_lognormal(1:i) = .false. ! The 1st 3 variates
    l_d_variable_lognormal(i+1:pdf_dim) = .true.  ! Hydrometeors
    !---------------------------------------------------------------------------
    ! Generate a set of sample points for a microphysics/radiation scheme
    !---------------------------------------------------------------------------
    ! The old code was dealing with Covariance matrices. These were rescaled by
    ! Sigma'(i,j) = 1/sqrt(Sigma(i,i)) * Sigma(i,j) * 1/Sigma(j,j)
    ! to reduce the condition number of the matrices. Sigma' is the correlation
    ! matrix. This code deals directly with the correlation matrix. Hence we don't
    ! need any rescaling here.


    l_Sigma1_scaling = .false.
    l_Sigma2_scaling = .false.
    Sigma1_scaling = one
    Sigma2_scaling = one

    if ( X_mixt_comp_one_lev == 1 ) then

      Sigma1_Cholesky = zero ! Initialize the variance to zero
      ! Multiply the first three elements of the variance matrix by the
      ! values of the standard deviation of chi_1, eta_1, and w1

      call row_mult_lower_tri_matrix &
           ( pdf_dim, sigma1, corr_Cholesky_mtx_1, & ! In
             Sigma1_Cholesky ) ! Out

    elseif ( X_mixt_comp_one_lev == 2 ) then
      Sigma2_Cholesky = zero
      ! Multiply the first three elements of the variance matrix by the
      ! values of the standard deviation of s2, t2, and w2

      call row_mult_lower_tri_matrix &
           ( pdf_dim, sigma2, corr_Cholesky_mtx_2, & ! In
             Sigma2_Cholesky ) ! Out

    end if ! X_mixt_comp_one_lev == 1
    ! Compute the new set of sample points using the update variance matrices
    ! for this level

    call sample_points( pdf_dim, d_uniform_extra, &  ! intent(in)
                        mu1, mu2, &  ! intent(in)
                        l_d_variable_lognormal, & ! intent(in)
                        X_u_one_lev, & ! intent(in)
                        X_mixt_comp_one_lev, & ! intent(in)
                        Sigma1_Cholesky, Sigma2_Cholesky, & ! intent(in)
                        Sigma1_scaling, Sigma2_scaling, & ! intent(in)
                        l_Sigma1_scaling, l_Sigma2_scaling, & ! intent(in)
                        X_nl_one_lev ) ! intent(out)
    ! Zero precipitation hydrometeors if not in precipitation

    if ( .not. l_in_precip_one_lev ) then

      call zero_precip_hydromets( pdf_dim, & ! Intent(in)
                                  X_nl_one_lev ) ! Intent(inout)

    end if
    ! Clip extreme sample point values of chi, when necessary.
    ! The values of PDF component cloud fraction have been clipped within PDF
    ! closure under extreme conditions.  This code forces the sample point
    ! values of chi to be saturated or unsaturated to match the condition
    ! enforced by the clipping of PDF component cloud fraction.

    if ( l_clip_extreme_chi_sample_pts ) then

       if ( X_mixt_comp_one_lev == 1 ) then
          ! The sample is from the 1st PDF component.


          if ( cloud_frac_1 < epsilon( cloud_frac_1 ) ) then
             ! Cloud fraction in the 1st PDF component is 0.
             ! All sample point values of chi must be <= 0.

             if ( X_nl_one_lev(iiPDF_chi) > zero ) then
                ! Clip the sample point value of chi back to 0.
                X_nl_one_lev(iiPDF_chi) = zero
             endif ! X_nl_one_lev(iiPDF_chi) > zero

          elseif ( cloud_frac_1 > ( one - epsilon( cloud_frac_1 ) ) ) then
             ! Cloud fraction in the 1st PDF component is 1.
             ! All sample point values of chi must be > 0.

             if ( X_nl_one_lev(iiPDF_chi) <= zero ) then
                ! Clip the sample point value of chi to epsilon.
                X_nl_one_lev(iiPDF_chi) = epsilon( zero )
             endif ! X_nl_one_lev(iiPDF_chi) <= zero

          endif ! cloud_frac_1

       elseif ( X_mixt_comp_one_lev == 2 ) then
          ! The sample is from the 2nd PDF component.


          if ( cloud_frac_2 < epsilon( cloud_frac_2 ) ) then
             ! Cloud fraction in the 2nd PDF component is 0.
             ! All sample point values of chi must be <= 0.

             if ( X_nl_one_lev(iiPDF_chi) > zero ) then
                ! Clip the sample point value of chi back to 0.
                X_nl_one_lev(iiPDF_chi) = zero
             endif ! X_nl_one_lev(iiPDF_chi) > zero

          elseif ( cloud_frac_2 > ( one - epsilon( cloud_frac_2 ) ) ) then
             ! Cloud fraction in the 2nd PDF component is 1.
             ! All sample point values of chi must be > 0.

             if ( X_nl_one_lev(iiPDF_chi) <= zero ) then
                ! Clip the sample point value of chi to epsilon.
                X_nl_one_lev(iiPDF_chi) = epsilon( zero )
             endif ! X_nl_one_lev(iiPDF_chi) <= zero

          endif ! cloud_frac_2

       endif ! X_mixt_comp_one_lev

    endif ! l_clip_extreme_chi_sample_pts


    return
  end subroutine transform_uniform_sample_to_pdf
!---------------------------------------------------------------------------------------------------

  subroutine zero_precip_hydromets( pdf_dim, X_nl_one_lev )
  ! Description:
  !   Sets the sample values of the precipitating hydrometeors to zero
  ! References:
  !   None
  !-----------------------------------------------------------------------------


      USE clubb_precision, ONLY: core_rknd 

      USE constants_clubb, ONLY: zero 

      USE array_index, ONLY: iipdf_ncn 

    implicit none
    ! Input Variables


    integer, intent(in) :: &
      pdf_dim ! Number of hydrometeors                                        [count]
    ! Input/Output Variables


    real( kind = core_rknd ), intent(inout), dimension(pdf_dim) :: &
      X_nl_one_lev      ! Sample of hydrometeors (normal-lognormal space)          [units vary]
    ! Local Variables

    integer :: &
      ivar              ! Loop counter                                             [count]
  !-----------------------------------------------------------------------------
    !----- Begin Code -----


    do ivar = iiPDF_Ncn+1, pdf_dim
      X_nl_one_lev(ivar) = zero
    end do

  end subroutine zero_precip_hydromets
!---------------------------------------------------------------------------------------------------

  subroutine sample_points( pdf_dim, d_uniform_extra, &
                            mu1, mu2,  &
                            l_d_variable_lognormal, &
                            X_u_one_lev, &
                            X_mixt_comp_one_lev, &
                            Sigma1_Cholesky, Sigma2_Cholesky, &
                            Sigma1_scaling, Sigma2_scaling, &
                            l_Sigma1_scaling, l_Sigma2_scaling, &
                            X_nl_one_lev )
! Description:
!   Generates n random samples from a d-dim Gaussian-mixture PDF.
!   Uses Latin hypercube method.
!   Original formulation takes samples only from the cloudy part of the grid box.
!   Revised formulation samples in and out of cloud.
!   We use MKS units on all variates.
! References:
!   None
!----------------------------------------------------------------------

      USE clubb_precision, ONLY: core_rknd 

    implicit none
    ! Input variables

    integer, intent(in) :: &
      pdf_dim, &    ! Number of variates
      d_uniform_extra   ! Variates included in uniform sample only
    ! Latin hypercube variables, i.e. chi, eta, w, etc.

    real( kind = core_rknd ), intent(in), dimension(pdf_dim) :: &
      mu1, mu2 ! d-dimensional column vector of means of 1st, 2nd components

    logical, intent(in), dimension(pdf_dim) :: &
      l_d_variable_lognormal ! Whether a given element of X_nl is lognormal

    real( kind = core_rknd ), intent(in), dimension(pdf_dim+d_uniform_extra) :: &
      X_u_one_lev ! Sample drawn from uniform distribution from particular grid level [-]

    integer, intent(in) :: &
      X_mixt_comp_one_lev ! Whether we're in the 1st or 2nd mixture component
    ! Columns of Sigma_Cholesky, X_nl_one_lev:  1   2   3   4 ... pdf_dim
    !                                           chi eta w   hydrometeors

    real( kind = core_rknd ), intent(in), dimension(pdf_dim,pdf_dim) :: &
      Sigma1_Cholesky, & ! [units vary]
      Sigma2_Cholesky

    real( kind = core_rknd ), intent(in), dimension(pdf_dim) :: &
      Sigma1_scaling, Sigma2_scaling ! Scaling factors on Sigma1,2 [units vary]

    logical, intent(in) :: &
      l_Sigma1_scaling, l_Sigma2_scaling ! Whether we're scaling Sigma1 or Sigma2
    ! Output Variables


    real( kind = core_rknd ), intent(out), dimension(pdf_dim) :: &
      X_nl_one_lev ! Sample that is transformed ultimately to normal-lognormal
    ! ---- Begin Code ----
    ! Generate n samples of a d-variate Gaussian mixture
    ! by transforming Latin hypercube points, X_u_one_lev.


    call gaus_mixt_points( pdf_dim, d_uniform_extra, mu1, mu2, &  ! intent(in)
                           Sigma1_Cholesky, Sigma2_Cholesky, & ! intent(in)
                           Sigma1_scaling, Sigma2_scaling, & ! intent(in)
                           l_Sigma1_scaling, l_Sigma2_scaling, & ! intent(in)
                           X_u_one_lev, X_mixt_comp_one_lev, & ! intent(in)
                           X_nl_one_lev ) ! intent(out)
    ! Convert lognormal variates (e.g. Ncn and rr) to lognormal

    where ( l_d_variable_lognormal )
      X_nl_one_lev(:) = exp( X_nl_one_lev(:) )
    end where

    return
  end subroutine sample_points
!-------------------------------------------------------------------------------
!----------------------------------------------------------------------

  subroutine gaus_mixt_points( pdf_dim, d_uniform_extra, mu1, mu2, & ! Intent(in)
                               Sigma1_Cholesky, Sigma2_Cholesky, & ! Intent(in)
                               Sigma1_scaling, Sigma2_scaling, & ! Intent(in)
                               l_Sigma1_scaling, l_Sigma2_scaling, & ! Intent(in)
                               X_u_one_lev, X_mixt_comp_one_lev, & ! Intent(in)
                               X_nl_one_lev ) ! Intent(out)
! Description:
!   Generates n random samples from a d-dimensional Gaussian-mixture PDF.
!   Uses Latin hypercube method.
! References:
!   None
!----------------------------------------------------------------------
!

      USE clubb_precision, ONLY: core_rknd 

    implicit none
    ! Input Variables


    integer, intent(in) :: &
      pdf_dim, &    ! Number of variates
      d_uniform_extra   ! Variates included in uniform sample only

    real( kind = core_rknd ), intent(in), dimension(pdf_dim) :: &
      mu1, mu2 ! d-dimensional column vector of means of 1st, 2nd Gaussians
    ! Latin hypercube sample from uniform distribution from a particular grid level

    real( kind = core_rknd ), intent(in), dimension(pdf_dim+d_uniform_extra) :: &
      X_u_one_lev

    real( kind = core_rknd ), dimension(pdf_dim,pdf_dim), intent(in) :: &
      Sigma1_Cholesky, Sigma2_Cholesky ! Cholesky factorization of Sigma1,2

    real( kind = core_rknd ), dimension(pdf_dim), intent(in) :: &
      Sigma1_scaling, & ! Scaling factors for Sigma1 for accuracy [units vary]
      Sigma2_scaling    ! Scaling factors for Sigma2 for accuracy [units vary]

    logical, intent(in) :: &
      l_Sigma1_scaling, l_Sigma2_scaling ! Whether we're scaling Sigma1 or Sigma2

    integer, intent(in) :: &
      X_mixt_comp_one_lev ! Which mixture component we're in
    ! Output Variables


    real( kind = core_rknd ), intent(out), dimension(pdf_dim) :: &
      X_nl_one_lev ! [n by d] matrix, each row of which is a d-dimensional sample
    ! Local Variables


    real( kind = core_rknd ), dimension(pdf_dim) :: &
      std_normal  ! Standard normal multiplied by the factorized Sigma    [-]

    integer :: ivar ! Loop iterators
    ! ---- Begin Code ----
    ! From Latin hypercube sample, generate standard normal sample


#ifdef _MKL
    call vdcdfnorminv( pdf_dim, X_u_one_lev, std_normal )
#else
    do ivar = 1, pdf_dim
      std_normal(ivar) = ltqnorm( X_u_one_lev(ivar) )
    end do
#endif
      ! Determine which mixture fraction we are in.


    if ( X_mixt_comp_one_lev == 1 ) then

      call multiply_Cholesky &
          ( pdf_dim, std_normal, & ! In
            mu1, Sigma1_Cholesky, &  ! In
            Sigma1_scaling, l_Sigma1_scaling, & ! In
            X_nl_one_lev(1:pdf_dim) ) ! Out

    else if ( X_mixt_comp_one_lev == 2 ) then

      call multiply_Cholesky &
           ( pdf_dim, std_normal, & ! In
             mu2, Sigma2_Cholesky, &  ! In
             Sigma2_scaling, l_Sigma2_scaling, & ! In
             X_nl_one_lev(1:pdf_dim) ) ! Out

    else
      print *, X_mixt_comp_one_lev
      stop "Error determining mixture component in gaus_mixt_points"

    end if ! X_mixt_comp_one_lev

    return
  end subroutine gaus_mixt_points
!-------------------------------------------------------------------------------
!-----------------------------------------------------------------------

  function ltqnorm( p_core_rknd )
! Description:
!   This function is ported to Fortran from the same function written in Matlab,
!    see the following description of this function.  Hongli Jiang, 2/17/2004
!   Converted to double precision by Vince Larson 2/22/2004;
!    this improves results for input values of p near 1.
! LTQNORM Lower tail quantile for standard normal distribution.
!   Z = LTQNORM(P) returns the lower tail quantile for the standard normal
!   distribution function.  I.e., it returns the Z satisfying Pr{X < Z} = P,
!   where X has a standard normal distribution.
!   LTQNORM(P) is the same as SQRT(2) * ERFINV(2*P-1), but the former returns a
!   more accurate value when P is close to zero.
!   The algorithm uses a minimax approximation by rational functions and the
!   result has a relative error less than 1.15e-9. A last refinement by
!   Halley's rational method is applied to achieve full machine precision.
!   Author:      Peter J. Acklam
!   Time-stamp:  2003-04-23 08:26:51 +0200
!   E-mail:      pjacklam@online.no
!   URL:         http://home.online.no/~pjacklam
!-----------------------------------------------------------------------

!
!


      USE clubb_precision, ONLY: core_rknd, dp 

      USE constants_clubb, ONLY: sqrt_2_dp, sqrt_2pi_dp, two_dp, one_dp, one_half_dp 
    ! Some compilers cannot handle 1.0/0.0, so in CAM we import their
    ! +Inf and -Inf constants. We REALLY should find a better way to
    ! do this.
    ! Eric Raut, 24 Feb 2016


    implicit none
    ! External


    intrinsic :: log, sqrt, exp
    ! Constant Parameter
    ! Apply Halley's method to answer to achieve more accurate result


    logical, parameter :: &
      l_apply_halley_method = .true.
    ! Input Variable(s)


    real( kind = core_rknd ), intent(in) :: p_core_rknd
    ! Return Variable


    real( kind = core_rknd ) :: ltqnorm
    ! Local Variable(s)

    real( kind = dp ) :: p

    real( kind = dp ) a1, a2, a3, a4, a5, a6, b1, b2, b3, b4, b5, &
                     c1, c2, c3, c4, c5, c6, d1, d2, d3, d4

    real( kind = dp ) q, r, z, z1, plow, phigh

    real( kind = dp ) ::  e, u
! Coefficients in rational approximations.
! equivalent: a(1)=a1, a(2)=a2, and etc, when a(1) is in Matlab.
! Similarly for b, c, and d's

    parameter (a1 = -3.969683028665376E+01_dp,  &
               a2 = 2.209460984245205E+02_dp, &
               a3 = -2.759285104469687E+02_dp,  &
               a4 = 1.383577518672690E+02_dp, &
               a5 = -3.066479806614716E+01_dp,  &
               a6 = 2.506628277459239E+00_dp)
    parameter (b1 = -5.447609879822406E+01_dp,  &
               b2 = 1.615858368580409E+02_dp, &
               b3 = -1.556989798598866E+02_dp,  &
               b4 = 6.680131188771972E+01_dp, &
               b5 = -1.328068155288572E+01_dp)
    parameter (c1 = -7.784894002430293E-03_dp,  &
               c2 = -3.223964580411365E-01_dp, &
               c3 = -2.400758277161838E+00_dp,  &
               c4 = -2.549732539343734E+00_dp, &
               c5 =  4.374664141464968E+00_dp,  &
               c6 =  2.938163982698783E+00_dp)
    parameter (d1 =  7.784695709041462E-03_dp,  &
               d2 =  3.224671290700398E-01_dp, &
               d3 =  2.445134137142996E+00_dp,  &
               d4 =  3.754408661907416E+00_dp)

    p = real( p_core_rknd, kind=dp )
    ! Default initialization

    z = 0.0_dp
!  Define break-points.

    plow  = 0.02425_dp
    phigh = 1._dp - plow
!  Initialize output array. Don't need this in Fortran
!   z = zeros(size(p));
!  Rational approximation for lower region:


    if (p > 0._dp .and. p < plow) then
      q = sqrt( -2._dp * log( p ) )
      z = (((((c1*q+c2)*q+c3)*q+c4)*q+c5)*q+c6)/ &
                ((((d1*q+d2)*q+d3)*q+d4)*q+1._dp)
!  Rational approximation for central region:
    else if (p >= plow .and. p <= phigh) then
      q = p - 0.5_dp
      r = q * q
      z = (((((a1*r+a2)*r+a3)*r+a4)*r+a5)*r+a6)*q &
                 /(((((b1*r+b2)*r+b3)*r+b4)*r+b5)*r+1._dp)
! Rational approximation for upper region:
    else if (p > phigh .and. p < 1._dp) then
      q  = sqrt( -2._dp * log(1._dp - p) )
      z  = -(((((c1*q+c2)*q+c3)*q+c4)*q+c5)*q+c6) &
                  /((((d1*q+d2)*q+d3)*q+d4)*q+1._dp)
    end if
    ! Eric Raut note: In CAM, we use CAM's predefined infinity and nan
    ! constants to avoid dividing by zero. We don't have similar constants
    ! in CLUBB or None "cores", so we have to divide by zero. We should
    ! fix this. --24 Feb 2016
! Case when P = 1:, z=+inf

    if(p == 1._dp)then
       ! For kgen kernel debugging
       print *, "INFP"
    end if
!  Case when P = 0: z = -inf

    if (p == 0._dp) then
       ! For kgen kernel debugging
       print *, "INFN"
    end if
!  Cases when output will be NaN:
!   k = p < 0 | p > 1 | isnan(p);

    if (p < 0._dp .or. p > 1._dp) then
       ! For kgen kernel debugging
       print *, "NAN"
    end if
!  The relative error of the approximation has absolute value less
!  than 1.15e-9. One iteration of Halley's rational method (third
!  order) gives full machine precision.
! V. Larson 20Feb04: Don't use the following if-end if loop.
!   The value of e is very different than what MATLAB produces,
!   possibly because of
!   poor values of erf from Numerical Recipes.
!   The value is close to MATLAB's
!   if I omit the following if-end if loop.
! End V. Larson comment
    ! Halley's rational method is applied to achieve a more accurate result if
    ! the flag below is true. In tests, this did increase the runtime of None
    ! slightly but did improve results.
    ! Eric Raut 23Aug14


    if ( l_apply_halley_method ) then
      e = one_half_dp * erfc(-z/sqrt_2_dp) - p !!! UNRESOLVED !!! erfc
      u = e * sqrt_2pi_dp * exp( (z**2) / two_dp )
      z = z - u / ( one_dp + z*u/two_dp )
    end if
! return z as double precision:

    ltqnorm = real( z, kind=core_rknd )

    return
  end function ltqnorm
!-------------------------------------------------------------------------------

  subroutine multiply_Cholesky( pdf_dim, std_normal, mu, Sigma_Cholesky, &
                                  Sigma_scaling, l_scaled, &
                                  nonstd_normal )
! Description:
!   Computes the nonstd_normal from the Cholesky factorization of Sigma,
!   std_normal, and mu.
!   nonstd_normal = Sigma_Cholesky * std_normal + mu.
! References:
!   M. E. Johnson (1987), ``Multivariate Normal and Related Distributions'' p50-55
!-------------------------------------------------------------------------------


      USE clubb_precision, ONLY: core_rknd 

    implicit none

    external :: dtrmv ! BLAS upper/lower triangular multiplication subroutine
    ! Parameters

    integer, parameter :: &
      incx = 1 ! Increment for x in dtrmv
    ! Input Variables

    integer, intent(in) :: pdf_dim! Number of variates (normally=5)

    real( kind = core_rknd ), intent(in), dimension(pdf_dim) :: &
      std_normal ! vector of d-variate standard normal distribution [-]

    real( kind = core_rknd ), intent(in), dimension(pdf_dim) :: &
      mu ! d-dimensional column vector of means of Gaussian     [units vary]

    real( kind = core_rknd ), intent(in), dimension(pdf_dim,pdf_dim) :: &
      Sigma_Cholesky ! Cholesky factorization of the Sigma matrix [units vary]

    real( kind = core_rknd ), intent(in), dimension(pdf_dim) :: &
      Sigma_scaling ! Scaling for Sigma / mu    [units vary]

    logical, intent(in) :: l_scaled ! Whether any scaling was done to Sigma
    ! Output Variables
    ! nxd matrix of n samples from d-variate normal distribution
    !   with mean mu and covariance structure Sigma


    real( kind = core_rknd ), intent(out) :: &
      nonstd_normal(pdf_dim)
    ! Local Variables

    real( kind = core_rknd ), dimension(pdf_dim) :: &
      Sigma_times_std_normal ! Sigma * std_normal [units vary]
    ! --- Begin Code ---


    Sigma_times_std_normal = std_normal ! Copy std_normal into 'x'
    ! Call the level 2 BLAS subroutine to multiply std_normal by Sigma_Cholesky


    if ( kind( 0.0_core_rknd ) == kind( 0.0D0 ) ) then
      ! core_rknd is double precision

      call dtrmv( 'Lower', 'N', 'N', pdf_dim, Sigma_Cholesky, pdf_dim, & ! In
                  Sigma_times_std_normal, & ! In/out
                  incx ) ! In

    else if ( kind( 0.0_core_rknd ) == kind( 0.0 ) ) then
      ! core_rknd is single precision

      call strmv( 'Lower', 'N', 'N', pdf_dim, Sigma_Cholesky, pdf_dim, & ! In
                  Sigma_times_std_normal, & ! In/out
                  incx ) ! In !!! UNRESOLVED !!! strmv

    else
      ! core_rknd is neither single precision nor double precision

      stop "Cannot call dtrmv or strmv in multiply_Cholesky"

    end if

    if ( l_scaled ) then
      ! Add mu to Sigma * std_normal (scaled)
      nonstd_normal = Sigma_times_std_normal + mu * Sigma_scaling
      ! Determine 'y' vector by removing the scaling factors
      nonstd_normal = nonstd_normal / Sigma_scaling
    else
      ! Add mu to Sigma * std_normal
      nonstd_normal = Sigma_times_std_normal + mu
    end if

    return
  end subroutine multiply_Cholesky
!-----------------------------------------------------------------------


end module transform_to_pdf_module
