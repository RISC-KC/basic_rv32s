# 캐시 구현

이 글에서는 RV32I47F 부터 사용될 Instruction Cache 및 Data Cache 에 대한 내용을 정리해보고자 한다.

## Instruction Cache

Instruction Cache 모듈은 Instruction Memory 와 함께 명령어를 보관하여 전달하는 역할을 한다. Instruciton Memory 는 ROM 으로 간주하기 때문에 Instruction Cache 모듈에서 Instruciton Memory 로 쓰기가 일어나는 일은 없다. 읽기의 경우, Instruction Cache 에서 cache miss 가 발생하면 Instruction Memory 에서 읽어와야 하는데, 우리 구현에서는 접근을 동시에 실행하여 cache miss 가 일어났을 때 Instruction Memory 에서 불러오는 시간을 줄일 것이다. KHWL 과 나는 이 방식을 SAA (Simultaneous Address Access) 라고 부르기로 했다.

현재 RV32I37F 까지의 Instruction Memory 의 크기는 4KB 이다. 이에 맞추어 Instruciton Cache 의 용량은 256B 로 책정하였다.

Instruction Cache 가 256B 의 용량을 가지게 되면 64 개의 Word 를 가지는데, 나는 2-way wet associative 방식으로 구현할 것이므로 주소 접근은 10비트 중 하위 5비트로 하고, Tag 를 나머지 상위 5비트로 잡을 것이다.

## Data Cache

Data Cache 모듈은 Data Cache 와 함께 데이터를 보관하고, 보내고, 저장하는 역할을 한다. Data Memory 는 Instruction Memory 와 달리 ROM 이 아닌 RAM 등으로 간주하기 때문에 Data Cache 에서 Data Memory 로 쓰기가 일어나야 한다. 이 때 write back 방식을 이용하여 구현할 것이다. 읽기의 경우 Instruction Cache 와 마찬가지로 SAA 방식을 적용할 것이다.

현재 RV32I37F 까지의 Data Memory 의 크기도 4KB 이다. 이에 맞추어 Data Cache 의 용량도 256B 로 책정하였다.

Data Cache 가 256B 의 용량을 가지게 되면 64 개의 Word 를 가지는데, 나는 2-way wet associative 방식으로 구현할 것이므로 주소 접근은 10비트 중 하위 5비트로 하고, Tag 를 나머지 상위 5비트로 잡을 것이다.