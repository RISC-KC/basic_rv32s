# MMIO Interface design

[입력신호]
CLK
CLK_enable
Reset
data_memory_write_data          (from Byte Enable Logic)
data_memory_write_enable        (from EX_MEM_Register)
data_memory_address(ALUresult)  (from EX_MEM_Register)
UART_busy                       (from UART_TX; uart_busy)

[출력신호]
mmio_uart_tx_data    (to UART_TX)
mmio_uart_tx_start   (to UART_TX)
mmio_uart_tx_status   (to UART_TX)
mmio_uart_status_hit (to DM-UART_MUX)

[Logics]
- 주소 정의
    - 0x10010000 = UART TX에 출력될 주소
    - 0x10010004 = UART 의 status, 즉 busy인지를 타나내는 주소.
- MMIO 인터페이스에서 Data Memory의 주소를 항상 입력받으며 주소가 정의된 값인지 계속 비교한다.
- UART_TX 모듈로부터 uart_busy인지 계속 관찰한다.
- 비교 시 주소영역에 속할 경우
    - 0x10010000 = UART_TX_ADDR일 경우
        - (쓰기) Write Enable 되어있을 시 UART_busy가 아닐 때 해당 주소에 쓰여지는 값 data_memory_write_data를 동시에 UART_TX로 보낸다.
        - (읽기) Write Enable이 안되어있을 경우 아무것도 하지 않는다. 데이터 메모리에도 아무값 쓰여지지 않는다. 데이터 메모리에서 실제로 인출된 값이 MEM_WB_Register로 출력된다. 
    - 0x10010004 = UART_STATUS_ADDR일 경우
        - (쓰기) Write Enable 시 아무것도 하지 않는다. 데이터 메모리에도 쓰여지지 않는다. (Read Only. 프로그램 외 기계적 동작으로만 변함.)
        - (읽기) MMIO Interface에서 모니터링하던 UART_busy에 따라 현재 1인지 0인지 출력한다. 이 값은 DM_UART_MUX에서 MMIO Interface의 mmio_uart_tx_status_hit 신호를 통해 기존에는 신호가 0이라 Data Memory의 값을 선택하다가 MEM단계 읽기 주소가 0x10010004가 되었을 때 신호가 1이되어 현재 읽어온 UART_busy 값을 선택해 MEM_WB_Register에 사실상 DM_RD로서 출력하게된다.
- UART_busy가 1이라면 구현한 printf에서 항상 tx_busy를 모니터링하며 tx_busy = 0일 때만 putchar을 실행하므로 소프트웨어가 polling하는 방식을 사용한다.
- MEM 단계의 신호를 입력받아 조합논리로 판단하고 해당 clock edge에서 uart_tx_data 레지스터에 저장한다. 다음 사이클부터 UART_TX가 직렬 전송을 시작.
- Data Memory는 그대로 동작한다. 변경사항 없다.

[Note]

아직 탑모듈 검증 안됨