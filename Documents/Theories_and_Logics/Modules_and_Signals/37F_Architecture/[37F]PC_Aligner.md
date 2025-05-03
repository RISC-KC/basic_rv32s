# PC Aligner

[입력신호]
U_NextPC    (from PCC)

[출력신호]
NextPC      (to PC)

[Logics]
PCC에서 출력되는 다음 PC주소인 U_NextPC를 4바이트 단위에 맞게 하위 2비트를 00으로 강제 정렬한다.
정렬된 주소는 NextPC가 되며 Program Counter로 출력된다. 
정렬을 위해 & ~1연산을 수행한다. 

[Note]
- Instruction Misalignment를 방지하기 위한 모듈.
Machine Level의 Exception 관련 설계 구현이 되어있지 않기 때문에 이를 원천적으로 방지하고자 고안되었다. 

- 기존의 J_Aligner로서 J_Target만을 정렬하는 모듈이었지만 Revision 4 이후 PCC의 U_NextPC 자체를 정렬하는 모듈로 바뀌었다. 
(RV32I37F.R4)