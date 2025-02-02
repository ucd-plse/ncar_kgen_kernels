!KGEN-generated Fortran source file 
  
!Generated at : 2018-08-07 15:55:26 
!KGEN version : 0.7.3 
  


module wv_sat_methods
! This portable module contains all CAM methods for estimating
! the saturation vapor pressure of water.
! wv_saturation provides CAM-specific interfaces and utilities
! based on these formulae.
! Typical usage of this module:
! Init:
! call wv_sat_methods_init(r8, <constants>, errstring)
! Get scheme index from a name string:
! scheme_idx = wv_sat_get_scheme_idx(scheme_name)
! if (.not. wv_sat_valid_idx(scheme_idx)) <throw some error>
! Get pressures:
! es = wv_sat_svp_water(t, scheme_idx)
! es = wv_sat_svp_ice(t, scheme_idx)
! Use ice/water transition range:
! es = wv_sat_svp_trice(t, ttrice, scheme_idx)
! Note that elemental functions cannot be pointed to, nor passed
! as arguments. If you need to do either, it is recommended to
! wrap the function so that it can be given an explicit (non-
! elemental) interface.
    USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

!
!
!
!
!
!
!

    IMPLICIT NONE 
    PRIVATE 
    SAVE 

integer, parameter :: r8 = selected_real_kind(12) ! 8 byte real

real(r8) :: tmelt   ! Melting point of water at 1 atm (K)
real(r8) :: h2otrip ! Triple point temperature of water (K)
real(r8) :: tboil   ! Boiling point of water at 1 atm (K)


real(r8) :: epsilo  ! Ice-water transition range
real(r8) :: omeps   ! 1._r8 - epsilo
! Indices representing individual schemes

integer, parameter :: OldGoffGratch_idx = 0
integer, parameter :: GoffGratch_idx = 1
integer, parameter :: MurphyKoop_idx = 2
integer, parameter :: Bolton_idx = 3
! Index representing the current default scheme.

integer, parameter :: initial_default_idx = GoffGratch_idx
integer :: default_idx = initial_default_idx


INTERFACE wv_sat_svp_water
   MODULE PROCEDURE wv_sat_svp_water_r8
   MODULE PROCEDURE wv_sat_svp_water_v8
END INTERFACE wv_sat_svp_water
PUBLIC wv_sat_svp_water 

INTERFACE wv_sat_svp_ice
   MODULE PROCEDURE wv_sat_svp_ice_r8
   MODULE PROCEDURE wv_sat_svp_ice_v8
END INTERFACE wv_sat_svp_ice
PUBLIC wv_sat_svp_ice 
! pressure -> humidity conversion

INTERFACE wv_sat_svp_to_qsat
   MODULE PROCEDURE wv_sat_svp_to_qsat_r8
   MODULE PROCEDURE wv_sat_svp_to_qsat_v8
END INTERFACE wv_sat_svp_to_qsat
PUBLIC wv_sat_svp_to_qsat 
! Combined qsat operations

INTERFACE wv_sat_qsat_water
   MODULE PROCEDURE wv_sat_qsat_water_r8
   MODULE PROCEDURE wv_sat_qsat_water_v8
END INTERFACE wv_sat_qsat_water
PUBLIC wv_sat_qsat_water 

INTERFACE wv_sat_qsat_ice
   MODULE PROCEDURE wv_sat_qsat_ice_r8
   MODULE PROCEDURE wv_sat_qsat_ice_v8
END INTERFACE wv_sat_qsat_ice
PUBLIC wv_sat_qsat_ice 

INTERFACE goffgratch_svp_water
   MODULE PROCEDURE goffgratch_svp_water_r8
   MODULE PROCEDURE goffgratch_svp_water_v8
END INTERFACE goffgratch_svp_water


PUBLIC kr_externs_in_wv_sat_methods 
PUBLIC kr_externs_out_wv_sat_methods 

contains
!---------------------------------------------------------------------
! ADMINISTRATIVE FUNCTIONS
!---------------------------------------------------------------------
! Get physical constants


! Look up index by name.


! Check validity of an index from the above routine.


! Set default scheme (otherwise, Goff & Gratch is default)
! Returns a logical representing success (.true.) or
! failure (.false.).


! Reset default scheme to initial value.
! The same thing can be accomplished with wv_sat_set_default;
! the real reason to provide this routine is to reset the
! module for testing purposes.


!---------------------------------------------------------------------
! UTILITIES
!---------------------------------------------------------------------
! Get saturation specific humidity given pressure and SVP.
! Specific humidity is limited to range 0-1.


subroutine  wv_sat_svp_to_qsat_r8(es, p, qs)

  real(r8), intent(in)  :: es  ! SVP
  real(r8), intent(in)  :: p   ! Current pressure.
  real(r8), intent(out) :: qs
  ! If pressure is less than SVP, set qs to maximum of 1.

  if ( (p - es) <= 0._r8 ) then
     qs = 1.0_r8
  else
     qs = epsilo*es / (p - omeps*es)
  end if

end subroutine wv_sat_svp_to_qsat_r8

subroutine  wv_sat_svp_to_qsat_v8(es, p, qs, vlen)

  integer,  intent(in) :: vlen
  real(r8), intent(in)  :: es(vlen)  ! SVP
  real(r8), intent(in)  :: p(vlen)   ! Current pressure.
  real(r8), intent(out) :: qs(vlen)
  integer :: i
  ! If pressure is less than SVP, set qs to maximum of 1.
  do i=1,vlen 
     if ( (p(i) - es(i)) <= 0._r8 ) then
        qs(i) = 1.0_r8
     else
        qs(i) = epsilo*es(i) / (p(i) - omeps*es(i))
     end if
  enddo

end subroutine wv_sat_svp_to_qsat_v8

subroutine wv_sat_qsat_water_r8(t, p, es, qs, idx)
  !------------------------------------------------------------------!
  ! Purpose:                                                         !
  !   Calculate SVP over water at a given temperature, and then      !
  !   calculate and return saturation specific humidity.             !
  !------------------------------------------------------------------!
  ! Inputs

  real(r8), intent(in) :: t    ! Temperature
  real(r8), intent(in) :: p    ! Pressure
  ! Outputs
  real(r8), intent(out) :: es  ! Saturation vapor pressure
  real(r8), intent(out) :: qs  ! Saturation specific humidity

  integer,  intent(in), optional :: idx ! Scheme index

  call wv_sat_svp_water(t, es, idx)

  call wv_sat_svp_to_qsat(es, p, qs)
  ! Ensures returned es is consistent with limiters on qs.

  es = min(es, p)

end subroutine wv_sat_qsat_water_r8

subroutine wv_sat_qsat_water_v8(t, p, es, qs, vlen, idx)
  !------------------------------------------------------------------!
  ! Purpose:                                                         !
  !   Calculate SVP over water at a given temperature, and then      !
  !   calculate and return saturation specific humidity.             !
  !------------------------------------------------------------------!
  ! Inputs

  integer,  intent(in) :: vlen
  real(r8), intent(in) :: t(vlen)    ! Temperature
  real(r8), intent(in) :: p(vlen)    ! Pressure
  ! Outputs
  real(r8), intent(out) :: es(vlen)  ! Saturation vapor pressure
  real(r8), intent(out) :: qs(vlen)  ! Saturation specific humidity

  integer,  intent(in), optional :: idx ! Scheme index
  integer :: i

  call wv_sat_svp_water(t, es, vlen, idx)
  call wv_sat_svp_to_qsat(es, p, qs, vlen)
  do i=1,vlen
     ! Ensures returned es is consistent with limiters on qs.
     es(i) = min(es(i), p(i))
  enddo

end subroutine wv_sat_qsat_water_v8

subroutine wv_sat_qsat_ice_r8(t, p, es, qs, idx)
  !------------------------------------------------------------------!
  ! Purpose:                                                         !
  !   Calculate SVP over ice at a given temperature, and then        !
  !   calculate and return saturation specific humidity.             !
  !------------------------------------------------------------------!
  ! Inputs

  real(r8), intent(in) :: t    ! Temperature
  real(r8), intent(in) :: p    ! Pressure
  ! Outputs
  real(r8), intent(out) :: es  ! Saturation vapor pressure
  real(r8), intent(out) :: qs  ! Saturation specific humidity

  integer,  intent(in), optional :: idx ! Scheme index

  call wv_sat_svp_ice(t, es, idx)

  call wv_sat_svp_to_qsat(es, p, qs)
  ! Ensures returned es is consistent with limiters on qs.

  es = min(es, p)

end subroutine wv_sat_qsat_ice_r8

subroutine wv_sat_qsat_ice_v8(t, p, es, qs, vlen, idx)
  !------------------------------------------------------------------!
  ! Purpose:                                                         !
  !   Calculate SVP over ice at a given temperature, and then        !
  !   calculate and return saturation specific humidity.             !
  !------------------------------------------------------------------!
  ! Inputs

  integer,  intent(in) :: vlen
  real(r8), intent(in) :: t(vlen)    ! Temperature
  real(r8), intent(in) :: p(vlen)    ! Pressure
  ! Outputs
  real(r8), intent(out) :: es(vlen)  ! Saturation vapor pressure
  real(r8), intent(out) :: qs(vlen)  ! Saturation specific humidity

  integer,  intent(in), optional :: idx ! Scheme index
  integer :: i

  call wv_sat_svp_ice(t, es, vlen, idx)
  call wv_sat_svp_to_qsat(es, p, qs, vlen)
  do i=1,vlen
     ! Ensures returned es is consistent with limiters on qs.
     es(i) = min(es(i), p(i))
  enddo

end subroutine wv_sat_qsat_ice_v8


!---------------------------------------------------------------------
! SVP INTERFACE FUNCTIONS
!---------------------------------------------------------------------


subroutine  wv_sat_svp_water_r8(t, es, idx)
  real(r8), intent(in) :: t
  integer,  intent(in), optional :: idx
  real(r8), intent(out) :: es

  integer :: use_idx

  if (present(idx)) then
     use_idx = idx
  else
     use_idx = default_idx
  end if

  select case (use_idx)
  case(GoffGratch_idx)
     call GoffGratch_svp_water(t,es)
  case(MurphyKoop_idx)
     call MurphyKoop_svp_water(t,es)
  case(OldGoffGratch_idx)
     call OldGoffGratch_svp_water(t,es)
  case(Bolton_idx)
     call Bolton_svp_water(t,es)
  end select

end subroutine wv_sat_svp_water_r8

subroutine  wv_sat_svp_water_v8(t, es, vlen, idx)
  integer,  intent(in) :: vlen
  real(r8), intent(in) :: t(vlen)
  integer,  intent(in), optional :: idx
  real(r8), intent(out) :: es(vlen)
  integer :: i
  integer :: use_idx

  if (present(idx)) then
     use_idx = idx
  else
     use_idx = default_idx
  end if

  select case (use_idx)
  case(GoffGratch_idx)
     call GoffGratch_svp_water(t,es,vlen)
  case(MurphyKoop_idx)
     do i=1,vlen
        call MurphyKoop_svp_water(t(i),es(i))
     enddo
  case(OldGoffGratch_idx)
     do i=1,vlen
        call OldGoffGratch_svp_water(t(i),es(i))
     enddo
  case(Bolton_idx)
     do i=1,vlen
        call Bolton_svp_water(t(i),es(i))
     enddo
  end select

end subroutine wv_sat_svp_water_v8

subroutine wv_sat_svp_ice_r8(t, es, idx)
  real(r8), intent(in) :: t
  integer,  intent(in), optional :: idx
  real(r8), intent(out) :: es

  integer :: use_idx

  if (present(idx)) then
     use_idx = idx
  else
     use_idx = default_idx
  end if

  select case (use_idx)
  case(GoffGratch_idx)
     call GoffGratch_svp_ice(t,es)
  case(MurphyKoop_idx)
     call MurphyKoop_svp_ice(t,es)
  case(OldGoffGratch_idx)
     call OldGoffGratch_svp_ice(t,es)
  case(Bolton_idx)
     call Bolton_svp_water(t,es)
  end select

end subroutine wv_sat_svp_ice_r8

subroutine wv_sat_svp_ice_v8(t, es, vlen, idx)
  integer,  intent(in) :: vlen
  real(r8), intent(in) :: t(vlen)
  integer,  intent(in), optional :: idx
  real(r8), intent(out) :: es(vlen)
  integer :: i

  integer :: use_idx

  if (present(idx)) then
     use_idx = idx
  else
     use_idx = default_idx
  end if

  select case (use_idx)
  case(GoffGratch_idx)
     do i=1,vlen
        call GoffGratch_svp_ice(t(i),es(i))
     enddo
  case(MurphyKoop_idx)
     do i=1,vlen
        call MurphyKoop_svp_ice(t(i),es(i))
     enddo
  case(OldGoffGratch_idx)
     do i=1,vlen
        call OldGoffGratch_svp_ice(t(i),es(i))
     enddo
  case(Bolton_idx)
     do i=1,vlen
        call Bolton_svp_water(t(i),es(i))
     enddo
  end select

end subroutine wv_sat_svp_ice_v8

!---------------------------------------------------------------------
! SVP METHODS
!---------------------------------------------------------------------
! Goff & Gratch (1946)


subroutine GoffGratch_svp_water_r8(t, es)
  real(r8), intent(in)  :: t  ! Temperature in Kelvin
  real(r8), intent(out) :: es             ! SVP in Pa
  ! uncertain below -70 C

  es = 10._r8**(-7.90298_r8*(tboil/t-1._r8)+ &
       5.02808_r8*log10(tboil/t)- &
       1.3816e-7_r8*(10._r8**(11.344_r8*(1._r8-t/tboil))-1._r8)+ &
       8.1328e-3_r8*(10._r8**(-3.49149_r8*(tboil/t-1._r8))-1._r8)+ &
       log10(1013.246_r8))*100._r8

end subroutine GoffGratch_svp_water_r8

subroutine GoffGratch_svp_water_v8(t, es, vlen)
  integer :: vlen
  real(r8), intent(in)  :: t(vlen)  ! Temperature in Kelvin
  real(r8), intent(out) :: es(vlen) ! SVP in Pa
  integer :: i
  ! uncertain below -70 C

  do i=1,vlen
     es(i) = 10._r8**(-7.90298_r8*(tboil/t(i)-1._r8)+ &
       5.02808_r8*log10(tboil/t(i))- &
       1.3816e-7_r8*(10._r8**(11.344_r8*(1._r8-t(i)/tboil))-1._r8)+ &
       8.1328e-3_r8*(10._r8**(-3.49149_r8*(tboil/t(i)-1._r8))-1._r8)+ &
       log10(1013.246_r8))*100._r8
  enddo

end subroutine GoffGratch_svp_water_v8

subroutine GoffGratch_svp_ice(t, es)
  real(r8), intent(in)  :: t  ! Temperature in Kelvin
  real(r8), intent(out) :: es             ! SVP in Pa
  ! good down to -100 C

  es = 10._r8**(-9.09718_r8*(h2otrip/t-1._r8)-3.56654_r8* &
       log10(h2otrip/t)+0.876793_r8*(1._r8-t/h2otrip)+ &
       log10(6.1071_r8))*100._r8

end subroutine GoffGratch_svp_ice
! Murphy & Koop (2005)


subroutine MurphyKoop_svp_water(t, es)
  real(r8), intent(in)  :: t  ! Temperature in Kelvin
  real(r8), intent(out) :: es             ! SVP in Pa
  ! (good for 123 < T < 332 K)

  es = exp(54.842763_r8 - (6763.22_r8 / t) - (4.210_r8 * log(t)) + &
       (0.000367_r8 * t) + (tanh(0.0415_r8 * (t - 218.8_r8)) * &
       (53.878_r8 - (1331.22_r8 / t) - (9.44523_r8 * log(t)) + &
       0.014025_r8 * t)))

end subroutine MurphyKoop_svp_water

subroutine MurphyKoop_svp_ice(t, es)
  real(r8), intent(in) :: t  ! Temperature in Kelvin
  real(r8) :: es             ! SVP in Pa
  ! (good down to 110 K)

  es = exp(9.550426_r8 - (5723.265_r8 / t) + (3.53068_r8 * log(t)) &
       - (0.00728332_r8 * t))

end subroutine MurphyKoop_svp_ice
! Old CAM implementation, also labelled Goff & Gratch (1946)
! The water formula differs only due to compiler-dependent order of
! operations, so differences are roundoff level, usually 0.
! The ice formula gives fairly close answers to the current
! implementation, but has been rearranged, and uses the
! 1 atm melting point of water as the triple point.
! Differences are thus small but above roundoff.
! A curious fact: although using the melting point of water was
! probably a mistake, it mildly improves accuracy for ice svp,
! since it compensates for a systematic error in Goff & Gratch.


subroutine OldGoffGratch_svp_water(t,es)
  real(r8), intent(in)  :: t
  real(r8), intent(out) :: es
  real(r8) :: ps, e1, e2, f1, f2, f3, f4, f5, f

  ps = 1013.246_r8
  e1 = 11.344_r8*(1.0_r8 - t/tboil)
  e2 = -3.49149_r8*(tboil/t - 1.0_r8)
  f1 = -7.90298_r8*(tboil/t - 1.0_r8)
  f2 = 5.02808_r8*log10(tboil/t)
  f3 = -1.3816_r8*(10.0_r8**e1 - 1.0_r8)/10000000.0_r8
  f4 = 8.1328_r8*(10.0_r8**e2 - 1.0_r8)/1000.0_r8
  f5 = log10(ps)
  f  = f1 + f2 + f3 + f4 + f5

  es = (10.0_r8**f)*100.0_r8
  
end subroutine OldGoffGratch_svp_water

subroutine OldGoffGratch_svp_ice(t,es)
  real(r8), intent(in) :: t
  real(r8), intent(out) :: es
  real(r8) :: term1, term2, term3

  term1 = 2.01889049_r8/(tmelt/t)
  term2 = 3.56654_r8*log(tmelt/t)
  term3 = 20.947031_r8*(tmelt/t)

  es = 575.185606e10_r8*exp(-(term1 + term2 + term3))
  
end subroutine OldGoffGratch_svp_ice
! Bolton (1980)
! zm_conv deep convection scheme contained this SVP calculation.
! It appears to be from D. Bolton, 1980, Monthly Weather Review.
! Unlike the other schemes, no distinct ice formula is associated
! with it. (However, a Bolton ice formula exists in CLUBB.)
! The original formula used degrees C, but this function
! takes Kelvin and internally converts.


subroutine Bolton_svp_water(t, es)
  real(r8),parameter :: c1 = 611.2_r8
  real(r8),parameter :: c2 = 17.67_r8
  real(r8),parameter :: c3 = 243.5_r8

  real(r8), intent(in)  :: t  ! Temperature in Kelvin
  real(r8), intent(out) :: es             ! SVP in Pa

  es = c1*exp( (c2*(t - tmelt))/((t - tmelt)+c3) )

end subroutine Bolton_svp_water

!read state subroutine for kr_externs_in_wv_sat_methods 
SUBROUTINE kr_externs_in_wv_sat_methods(kgen_unit) 
    INTEGER, INTENT(IN) :: kgen_unit 
    LOGICAL :: kgen_istrue 
    REAL(KIND=8) :: kgen_array_sum 
      
    READ (UNIT = kgen_unit) tmelt 
    READ (UNIT = kgen_unit) h2otrip 
    READ (UNIT = kgen_unit) tboil 
    READ (UNIT = kgen_unit) epsilo 
    READ (UNIT = kgen_unit) omeps 
    READ (UNIT = kgen_unit) default_idx 
END SUBROUTINE kr_externs_in_wv_sat_methods 
  
!read state subroutine for kr_externs_out_wv_sat_methods 
SUBROUTINE kr_externs_out_wv_sat_methods(kgen_unit) 
    INTEGER, INTENT(IN) :: kgen_unit 
      
    LOGICAL :: kgen_istrue 
    REAL(KIND=8) :: kgen_array_sum 
END SUBROUTINE kr_externs_out_wv_sat_methods 
  
end module wv_sat_methods
