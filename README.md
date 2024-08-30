# VHDL--5
Accelerator for AI Computation
## Project 목표
![image](https://github.com/user-attachments/assets/75e7aacc-b0a6-416e-bc24-d12be32d33db)
본 Project의 목표는 RISC CPU를 구성하고 이것과 결합된 인공지능연산을 돕는 가속기 모듈을 구성하는 것이다. 
instruction을 1cycle마다 실행하여 속도를 높이기 위해 MIPS Pipeline CPU를 제작하였고 hazard를 방지하기 위해 stall을 구현 하였다. 
CPU에서 처리되는 간단한 명령어 외에도 추가로 복잡한 Matrix연산과 Convolution을 구현할 수 있는 모듈을 연결하여 인공지능연산을 돕는 가속기 모듈로 시스템을 구성하였다
![image](https://github.com/user-attachments/assets/4fcedc33-368c-404c-92d9-214bc9474124)

# 1. CPU

## 1-1. opcode.
R-Format과 I-Format 모두 16bit로 구성하여 instruction을 입력받고 각각의 부분에 맞게 할당한다. 

R-Format : opcode 4bit, register 번호 2bit씩 할당하여 rs, rt, rd 총 6 bit의 크기를 차지, opcode로 먼저 R-Format인지 확인하는 작업을 거치게 된다. 
나머지는 function 6bit로 이루어지고 R-Format에 어느 연산을 수행하게 될지 판단한다.
I-Format ; opcode 4bit, register 번호 2bit씩 할당하여 rs, rt 총 4bit의 크기를 차지, constant로 addi와 같은 immediate 연산을 하거나 address를 받아 branch를 하는 과정을 진행하도록 하였다.

## 1-2. control
입력된 16bit의 instruction이 어떤 방식으로 control signal에 따라 연산을 하고 할당이 되는지 볼 수 있다. 

instruction을 구분하여 opcode 4bit와 function bit가 존재하는 경우 이를 비교, control 신호를 할당하여 ALU와 CPU모듈의 동작을 제어한다. 
Hazard Detector, Branch Miss Prediction등의 신호를 받아 pipeline register을 제어한다

## 1-3. Hazard Detector
입력된 16bit의 instruction을 구분해 어느 시점에 stall을 줄지 말지 결정하는 모습을 볼 수 있다

ALU나 SW, LW동작을 연속하여 실행할 때, 예를들면 ID_EX hazard 또는 EX_MEM hazard와 같이 register의 연산 결과가 WB 과정에 도달하지 못했는데 다음 instruction에서 연산이 필요한 경우에 발생하는 문제점들을 HazardDetector로 Hazard를 감지하고, stall시행의 여부를 결정한다.

## 1-4. Register File
입력된 address가 register의 어느 곳에 할당되는지 확인 할 수있다

총 64bit 크기로 이루어져 있으며, 16bit씩 네 부분으로 나뉘어져 있다. 각각 이진수로 00, 01, 10, 11 register 번호에 해당하는 값들을 저장할 수 있다. 
control 모듈의 control signal 신호를 받아 ALU의 값을 register에 저장할지 정한다.

## 1-5. ALU
ALU에서 맡은 연산과 그 결과를 어떻게 나타나게 하는지에 대해 볼 수 있다.

각 instruction에 따라 결정된 control signal들에 의해 OP값 3bit가 결정되고, register주소에 할당된 값을 불러와 ADD, SUB, OR, AND등 간단한 계산을 포함해, 추가적인 R-Format 연산들과 branch를 위해 필요한 연산 등 다양한 연산을 수행하고자 하였다.

## 6. CPU
필요한 control 신호 및, 값들을 한 clock이 반복될 때 마다 저장되는 모습을 볼 수 있다.

cpu.sv 모듈 안에는 총 4개 단계의 pipeline register(IF/ID, ID/EX, EX/MEM, MEM/WB pipeline registers)들이 정의되어있고 각각의 단계에 따라 필요한 정보들을 저장하고 있다. 
pipeline register에 저장되어있는 값들을 바탕으로 alu, control, HazardDetector, RegisterFile, BranchPrediction을 비롯하여 NPU연산에 필요한 값들 또한 각 모듈로 전달되어 수행하도록 한다.

# 2. 인공지능연산가속기
![image](https://github.com/user-attachments/assets/e763a553-71be-4a67-9297-5fbe731ca583)
 Parallel Computing의 일종으로 Data Processing Unit이 Pipeline 구조로 지역적으로 연결되어 있는 구조인 Systolic Array를 사용한다.

![image](https://github.com/user-attachments/assets/dfdda1d2-cd5b-4554-a060-1b67726412e5)
다음과 같이 processing element가 병렬 구조를 가지는 Eyeriss 구조로 인공지능연산 가속기를 구현하였다. 
이때 processing element는 데이터를 계산하고 독립적으로 연산을 하고 결과를 저장하며 인접한 unit에 데이터를 전달한다. pe는 reg file을 local memory로 가지므로 실제 memory에 접근하는 시간을 감소시킬 수 있다.

![image](https://github.com/user-attachments/assets/fc41a512-c813-44d8-bba4-9c3a80101275)
또한 행렬연산과 합성곱 모두 고정된 가중치를 사용하여 연산하므로 weight stationary 방식을 사용하여  memory에 접근하는 시간을 감소시킬 수 있다. 
두 연산 모두 3x3 pe를 기반으로 병렬연산하므로 단순계산으로 9배 이상 빨라졌음을 알 수 있다.
병렬 연산과 local memory의 사용으로 효율성을 높이고 속도를 증가시켰다는 점에서 ai 가속기에 적합한 모델임을 알 수 있다

# 2-1 Matrix Complication
![image](https://github.com/user-attachments/assets/24b302a8-4166-40df-a55b-62db3634496a)
인공 지능 연산에서 행렬 계산은 유용하게 쓰인다. 대표적으로는 위 그림과 같이 Neural Nerwork에서 각 노드가 입력 값을 받아 가중치와 곱한 후 activation 함수를 거쳐 출력값을 구하는 경우이다.
또한 MNIST Dataset을 분석할 때 사진에 대한 정보가 숫자로 이루어진 행렬값으로 들어와 이를 ai가 학습하는 경우나 역전파 알고리즘에도 행렬 연산이 이용된다.
그래서 이렇게 cpu에서 실행할 때 비효율적인 연산을 인공 지능 연산 가속기 모듈로 진행하면 훨씬 빠른 속도를 얻을 수 있다.

![image](https://github.com/user-attachments/assets/189afb00-484a-4d0e-88f9-249f795d7459)Convolution 연산을 실제로 수행하는 요소이다. 각 PE는 입력 데이터와 필터의 일부
분을 받아서 곱셈 및 덧셈 연산을 수행한다. 설계할 때는 pe 3x3으로 3x3입력을 받아 
convolution이 가능하게 만들었다.
상기 이미지에 나타난 구조를 목표로 삼았다. 각 3 x 3크기의 cell들은 mac으로 구성되어 있으며, 9개의 mac을 mmu가 감싸고 있는 모습이다

# 2-2 MAC
MAC으로 들어오는 Input, Weight를 곱한다. input은 좌에서 우로, weight와 계산 결과값은 위에서 아래로 모듈 간 전달된다.

# 2-3 MMU
전체 Input, Output과 모듈들을 연결하며, 모듈 간 정보 전달 경로를 정의한다. 데이터의 input과 weight가 행렬로 들어온다면, 1차원 행렬로 펴서 입력하게 된다. 그럼 MMU 모듈에서 이 입력들을 slicing하여 각 행, 열에 맞는 모듈로 전달한다. 
이후 계산된 출력값을 다시 행렬에 재배정함으로써 기존 얻고자 했던 결과를 얻을 수 있다.

# 2-4 합성결과
![image](https://github.com/user-attachments/assets/3a3403e7-5aec-415e-a0ad-57fdace53aae)
![image](https://github.com/user-attachments/assets/3cc9c9c4-e160-4443-aeac-3c2a2a24135c)

# 3 Convolution
![image](https://github.com/user-attachments/assets/511e5056-0640-466e-a3ea-bf768ce0e170)
 Convolution 연산은 신호 처리, 이미지 처리, 신경망 등 다양한 분야에서 사용되는 핵심 연산이다. 주로 이미지 필터링, 경계 검출, 특징 추출등의 작업에 사용되고 이번 설계에서는 3x3행렬의 convolution을 진행하였다. 
convolution 연산은 입력 이미지와 커널을 통해 출력 이미지를 생성하는 것으로 많이 알려져 있고, 입력 이미지의 특정 부분과 곱셈 및 덧셈 연산을 수행하여 출력 이미지를 생성한다.
 convolution의 연산 과정으로,
 1) 커널이 입력 이미지의 좌측 상단에서 시작하여 전체 이미지를 스캔, 커널이 이미지 위를 이동하면서 각 위치에서 연산을 수행함
2) 커널의 각 원소와 입력 이미지에 대응하는 원소를 곱한다. 곱셈 결과를 모두 더해 하나의 값을 생성함
3) 곱셈 및 덧셈 연산의 결과가 출력 이미지의 해당 위치에 저장되고 커널이 모든 위치를 스캔할 때까지 이 과정을 반복함
convolution 연산의 장점으로 여러 커널을 사용하여 동시에 연산을 수행할 수 있어 효율적이고, 이미지나 신호에서 유용한 특징을 추출하여 다음 단계에서 활용할 수 있다. 
인공지능 연산에 맞제 신경망(CNN)과 이미지 필터링에 주로 사용된다

# 3-1 input buffer
프로젝트에서 convolution 구조를 만들 때, input buffer를 추가하여 입력 비트 수를 맞춰주었다. 또한 input 데이터가 저장된 후 처리되기 전까지 일시적으로 보관할 수 있도록 설계했다. 
weight도 동일하게 input buffer에서 데이터를 저장하고, 이후 필요한 경우에 이것을 다음 유닛에 전달하는 역할을 한다. 
입력 데이터를 임시로 저장하는 역할을 하고, 이는 convolution 연산이 시작되기 전에 데이터를 버퍼링하여 안정적인 연산이 가능하도록 한다

# 3-2 Processing Elements (PE)
Convolution 연산을 실제로 수행하는 요소이다. 
각 PE는 입력 데이터와 필터의 일부분을 받아서 곱셈 및 덧셈 연산을 수행한다. 
설계할 때는 pe 3x3으로 3x3입력을 받아 convolution이 가능하게 만들었다.

# 3-3 Control Signal 
convolution을 포함한 인공지능 연산에 필요한 모듈을 제외하고 원래 alu와 관련된 control 신호만 사용하였으나, convolution 연산을 제어하는 신호로 이것은 연산의 시작과 종료, 데이터의 로드와 저장을 제어한다.

# 3-4 Output Register
연산 결과를 저장하는 레지스터로 이것은 최종 convolution 결과를 보관하며, 필요 시 다른 유닛으로 데이터를 전달하는 역할을 한다.

동작 방식으로는 데이터 로드 및 버퍼링으로 입력 데이터가 input buffer에 로드되고, 이 과정에서 control signal이 입력 데이터를 버퍼링한다. 
필터인 weights 도 마찬가지로 별도의 버퍼에 로드된다. 
다음으로 convolution 연산이 진행된다. processing elements는 입력 데이터와 필터의 일부분을 받아서 convolution 연산을 수행한다. 
각 PE는 곱셈 및 덧셈 연산을 통해 부분적인 convolution 결과를 생성한다. 이 부분적인 결과는 최종적으로 합산되어 output register에 저장된다.
마지막으로 결과 저장 및 출력으로 convolution 연산이 완료되면 결과는 output register에 저장된다. 
필요 시에 결과 데이터는 다음 유닛으로 전달된다. 
최적화를 위해 입력 데이터를 버퍼링하여 연산 중에 데이터에 접근하지 못하게 만들었고, 여러 개의 PE를 사용하여 병렬로 convolution 연산을 수행함으로써 연산 시간을 단축시켰다.
또한 연산의 시작과 종료를 효율적으로 제어하며 불필요한 대기 시간을 줄이는데 중점을 두었다

# 3-5 동작결과
![image](https://github.com/user-attachments/assets/8266cde8-714b-426d-900c-7ed57cf70316)

# 3-6 합성결과
![image](https://github.com/user-attachments/assets/9cdb9bff-e263-467a-a7d5-ac781391ab3e)
![image](https://github.com/user-attachments/assets/20738a21-ef2b-4d87-a121-d7767a534150)

![image](https://github.com/user-attachments/assets/44fd939c-b1aa-4d44-857b-29b5ab4dfb8d)

# 4. Verilator 시뮬레이션 결과
![image](https://github.com/user-attachments/assets/29b237bc-9155-45e8-94ff-97c5e20c1369)
![image](https://github.com/user-attachments/assets/2daf9620-7a5d-44a5-b994-8af6cc5c953e)
![image](https://github.com/user-attachments/assets/8eaaa784-5491-4a22-9d3d-2c0d0ee2eadd)
![image](https://github.com/user-attachments/assets/9dd6dec4-3516-4550-83c6-2de8dc206f29)
![image](https://github.com/user-attachments/assets/26acdbb0-1388-4c63-83de-3c85ef18ef72)
![image](https://github.com/user-attachments/assets/c24fed56-6835-45d9-94c7-d919938bed8d)
CPU의 기본연산(Add, sub, store word, load word, and, or 등과 matrix multiplication, convolution을 실행하여 결과 wave를 확인하였음.

