#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include "Vcpu.h"
//#include "Vcpu___024unit.h"
#include <verilated_vcd_c.h>  // For VCD tracing

#define WORD_SIZE 16
#define DATA_SIZE 24
#define MAX_SIM_TIME 260
vluint64_t sim_time=0;

int main(int argc, char **argv, char **env) {
    srand(time(NULL));

  // CPU 인스턴스화
  Vcpu* dut = new Vcpu;
  
  // VCD 파일을 위한 초기화
  Verilated::traceEverOn(true);
  VerilatedVcdC* m_trace = new VerilatedVcdC;
  
 // 트레이싱 설정
  dut->trace(m_trace, 5);
  m_trace->open("waveform.vcd");
  
  // Verilator 초기화
  Verilated::commandArgs(argc, argv);

  while (sim_time < MAX_SIM_TIME){
    if(sim_time==0){
      // 초기화 신호 설정
      dut->reset = 1;
      dut->i_data = 0b1111000000000000;
      dut->i_readM = 0;
      dut->i_writeM = 0;
      dut->i_address = 0;
      dut->d_data = 0;
      dut->d_readM = 0;
      dut->d_writeM = 0;
      dut->d_address = 0;
      uint16_t random_value1 = rand() % 65536; // 0에서 65535 사이의 랜덤 값 생성

    }
    else
    // 리셋 비활성화
      dut->reset = 0;
    if(sim_time==20){
      dut->i_data = 0b1000000100000001; // store words=> sw $1, 2($0)
      }
    if(sim_time==40)
      
      dut->i_data = 0b0111001100000001; // load words 
    if(sim_time==60)
      dut->i_data = 0b1111110110000000; // R-format, Add
    if(sim_time==80)
      dut->i_data = 0b1000001000001000; // store words
    if(sim_time==100)
      dut->i_data = 0b1111110110000001;
    if(sim_time==120)
      dut->i_data = 0b1000001000000001;
    dut->clk ^=1;
    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;
  }
    
    /*
    // Halt 신호 확인
    if (cpu->is_halted) {
    printf("CPU halted successfully.\n");
    } else {
    printf("CPU did not halt as expected.\n");
    }

    // 실행된 명령어 수 출력
    printf("Number of instructions executed: %d\n", cpu->num_inst);

    // 출력 포트 값 출력
    printf("Output port value: %h\n", cpu->output_port);
    */
    // 트레이스 파일 닫기
    m_trace->close();

    // 종료
    delete dut;
    exit(EXIT_SUCCESS);
  }
