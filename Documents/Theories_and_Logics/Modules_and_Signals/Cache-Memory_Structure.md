본 문서에서는 RV32I50F 코어 구조의 캐시-메모리 구조에 대해서 기술한다. 

RV32I50F 프로세서의 메모리 구조는 다음과 같다.
1. Instruction Memory
2. Instruction Cache
3. Data Memory
4. Data Cache

여기서 Instruction Memory와 Cache를 모아 Instruction 메모리 진영이라고 부르고,
Data Memory와 Cache를 모아 Data 메모리 진영이라고 부른다.

본 프로세서는 기본적인 Write-Back 캐시 쓰기 정책을 따르며,
추후 서술 될 STAA; Synchronized Total Address Access, 동기식 통합 주소 접근 방식을 읽기 정책으로 사용한다.

Instruction Memory는 현재 별도의 I/O를 지원하지 않는 프로세서 특성상 ROM이 탑재되어있다. 
Insturcion Cache는 때문에 비교적 동작방식이 단순하다.