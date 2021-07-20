!-----------------------------------------------------------------------
! Saturation specific humidity
!-----------------------------------------------------------------------
subroutine QSAT(water,P,T,Qs)

use, intrinsic :: iso_fortran_env, only: dp=>real64

use Constants, only : &
  eps,               &! Ratio of molecular weights of water and dry air
  e0,                &! Saturation vapour pressure at Tm (Pa)
  Tm                  ! Melting point (K)

implicit none

logical, intent(in) :: &
  water               ! Saturation wrt water if TRUE

real*8, intent(in) :: &
  P,                 &! Air pressure (Pa)
  T                   ! Temperature (K)

real*8, intent(out) :: &
  Qs                  ! Saturation specific humidity

real*8 :: &
  Tc,                &! Temperature (C)
  es                  ! Saturation vapour pressure (Pa)

Tc = T - Tm
if (Tc > 0 .or. water) then
  es = e0*exp(17.5043_dp*Tc / (241.3_dp + Tc))
else
  es = e0*exp(22.4422_dp*Tc / (272.186_dp + Tc))
end if
Qs = eps*es / P

end subroutine QSAT
