# Debug Interface (DI)

[입력신호]
DBG.input

[출력신호]
DBG.instr   (to DBG_RD_MUX)

[Logics]
ROM으로 구현. Debug Interface를 가정하여 별도의 명령어들을 담아뒀다.
DBG_RD_MUX에서 Dbg.Mode가 활성화되어 I_RD를 DBG.instr로 잡았을 때 본 모듈에 저장된 명령어가 인출되어 해당 명령어를 수행한다.

[Note]
디버거에 따른 디버그 인터페이스를 구현했어야하는데 너무 큰 소요가 예상되어
그를 가정하고 수행할 명령어를 담은 ROM으로 구현했다. 