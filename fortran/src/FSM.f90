!-----------------------------------------------------------------------
! Factorial Snow Model
!
! Richard Essery
! School of GeoSciences
! University of Edinburgh
!-----------------------------------------------------------------------
program FSM

use DIAGNOSTICS, only: &
  Nave                ! Number of timesteps in average outputs

implicit none

logical :: EoR        ! End-of-run flag

integer :: n          ! Timestep counter

call SET_PARAMETERS

call INITIALIZE

! Loop over timesteps
EoR = .false.
do
  do n = 1, Nave
    call DRIVE(EoR)
    if (EoR) goto 1
    call PHYSICS
  end do
  call OUTPUT
end do

1 continue

call DUMP

end program FSM
