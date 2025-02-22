import os
import matplotlib.pyplot as plt
from vcdvcd import VCDVCD

# VCD 파일 로드
vcd = VCDVCD("RV32I37F_tb_result.vcd")

# 결과 이미지를 저장할 폴더 생성 (없으면 생성)
output_dir = "subplots"
os.makedirs(output_dir, exist_ok=True)

# 시간 축 확장을 위한 scale factor (필요에 따라 조정)
time_scale = 100

# 각 신호에 대해 개별 이미지 생성
for signal in vcd.signals:
    tv_data = vcd[signal].tv
    # 신호 이름 단순화: 전체 경로 대신 마지막 부분만 사용
    simple_name = signal.split('.')[-1]
    
    fig, ax = plt.subplots(figsize=(12, 3))
    
    if tv_data:
        # 타임스탬프와 원래 값(2진 문자열) 분리
        timestamps, raw_values = zip(*tv_data)
        
        # 2진 문자열을 정수로 변환
        int_values = []
        for val in raw_values:
            try:
                int_val = int(val, 2)
            except ValueError:
                int_val = 0  # 변환 실패 시 0 처리
            int_values.append(int_val)
        
        # 고유 정수 값들을 정렬하고 균등한 인덱스로 매핑
        unique_values = sorted(set(int_values))
        mapping = {val: idx for idx, val in enumerate(unique_values)}
        # 실제 값 대신 균등한 인덱스로 대체
        mapped_values = [mapping[val] for val in int_values]
        
        # 시간 값 확장을 위해 time_scale 곱함
        scaled_timestamps = [t * time_scale for t in timestamps]
        
        # step plot으로 파형 그리기
        ax.step(scaled_timestamps, mapped_values, where="post", label=simple_name)
        
        # y축 tick은 균등 인덱스, tick label은 원래 정수 값을 16진수 형식으로 표시
        ticks = list(range(len(unique_values)))
        tick_labels = ["0x" + format(val, 'X') for val in unique_values]
        ax.set_yticks(ticks)
        ax.set_yticklabels(tick_labels)
    else:
        ax.plot([], [])
    
    ax.set_ylabel(simple_name, fontsize=10)
    ax.set_xlabel("Time", fontsize=12)
    ax.set_title(f"Waveform of {simple_name}", fontsize=14)
    ax.legend(loc="upper right", fontsize=8)
    ax.grid(True)
    
    plt.tight_layout()
    
    # 파일명에 특수문자 등 문제 없도록 단순화하여 저장
    file_name = f"{simple_name}.png"
    file_path = os.path.join(output_dir, file_name)
    
    # dpi 600으로 이미지 저장
    plt.savefig(file_path, dpi=600, bbox_inches="tight")
    plt.close(fig)