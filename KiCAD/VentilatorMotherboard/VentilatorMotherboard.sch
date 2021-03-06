EESchema Schematic File Version 4
LIBS:VentilatorMotherboard-cache
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector:Conn_01x02_Female JPOWER1
U 1 1 5E7EA39D
P 750 1350
F 0 "JPOWER1" H 642 1025 50  0000 C CNN
F 1 "Conn_01x02_Female" H 642 1116 50  0000 C CNN
F 2 "TerminalBlock:TerminalBlock_bornier-2_P5.08mm" H 750 1350 50  0001 C CNN
F 3 "~" H 750 1350 50  0001 C CNN
	1    750  1350
	-1   0    0    1   
$EndComp
$Comp
L Regulator_Linear:L7805 LR5V1
U 1 1 5E7EB51E
P 2800 1250
F 0 "LR5V1" H 2800 1492 50  0000 C CNN
F 1 "L7805" H 2800 1401 50  0000 C CNN
F 2 "Package_TO_SOT_THT:TO-220-3_Vertical" H 2825 1100 50  0001 L CIN
F 3 "http://www.st.com/content/ccc/resource/technical/document/datasheet/41/4f/b3/b0/12/d4/47/88/CD00000444.pdf/files/CD00000444.pdf/jcr:content/translations/en.CD00000444.pdf" H 2800 1200 50  0001 C CNN
	1    2800 1250
	1    0    0    -1  
$EndComp
$Comp
L Regulator_Linear:LM317_3PinPackage LR6V1
U 1 1 5E7ECBDE
P 2800 2250
F 0 "LR6V1" H 2800 2492 50  0000 C CNN
F 1 "LM317_3PinPackage" H 2800 2401 50  0000 C CNN
F 2 "Package_TO_SOT_THT:TO-220-3_Vertical" H 2800 2500 50  0001 C CIN
F 3 "http://www.ti.com/lit/ds/symlink/lm317.pdf" H 2800 2250 50  0001 C CNN
	1    2800 2250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR01
U 1 1 5E7F074F
P 2000 4400
F 0 "#PWR01" H 2000 4150 50  0001 C CNN
F 1 "GND" H 2005 4227 50  0000 C CNN
F 2 "" H 2000 4400 50  0001 C CNN
F 3 "" H 2000 4400 50  0001 C CNN
	1    2000 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	950  1350 2000 1350
Wire Wire Line
	2000 1350 2000 1550
Wire Wire Line
	2800 1550 2000 1550
Connection ~ 2000 1550
$Comp
L Device:R RFIXED6V1
U 1 1 5E7F5BA0
P 3200 2450
F 0 "RFIXED6V1" H 3270 2496 50  0000 L CNN
F 1 "220" H 3270 2405 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0204_L3.6mm_D1.6mm_P7.62mm_Horizontal" V 3130 2450 50  0001 C CNN
F 3 "~" H 3200 2450 50  0001 C CNN
	1    3200 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	3200 2650 3200 2600
Wire Wire Line
	3200 2300 3200 2250
Wire Wire Line
	3200 2250 3100 2250
Wire Wire Line
	2000 1550 2000 1650
Connection ~ 2100 1250
Wire Wire Line
	2100 1250 2500 1250
Wire Wire Line
	3200 2250 3500 2250
Connection ~ 3200 2250
$Comp
L Regulator_Linear:LM317_3PinPackage LR6V2
U 1 1 5E7F86E5
P 2800 3500
F 0 "LR6V2" H 2800 3742 50  0000 C CNN
F 1 "LM317_3PinPackage" H 2800 3651 50  0000 C CNN
F 2 "Package_TO_SOT_THT:TO-220-3_Vertical" H 2800 3750 50  0001 C CIN
F 3 "http://www.ti.com/lit/ds/symlink/lm317.pdf" H 2800 3500 50  0001 C CNN
	1    2800 3500
	1    0    0    -1  
$EndComp
$Comp
L Device:R_POT_TRIM RADJ6V2
U 1 1 5E7F86EF
P 2800 4100
F 0 "RADJ6V2" V 2685 4100 50  0000 C CNN
F 1 "R_POT_TRIM" V 2594 4100 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Piher_PT-10-V10_Vertical" H 2800 4100 50  0001 C CNN
F 3 "~" H 2800 4100 50  0001 C CNN
	1    2800 4100
	0    -1   -1   0   
$EndComp
Wire Wire Line
	2800 3950 2800 3900
$Comp
L Device:R RFIXED6V2
U 1 1 5E7F86FB
P 3200 3700
F 0 "RFIXED6V2" H 3270 3746 50  0000 L CNN
F 1 "220" H 3270 3655 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0204_L3.6mm_D1.6mm_P7.62mm_Horizontal" V 3130 3700 50  0001 C CNN
F 3 "~" H 3200 3700 50  0001 C CNN
	1    3200 3700
	1    0    0    -1  
$EndComp
Wire Wire Line
	3200 3900 3200 3850
Wire Wire Line
	3200 3550 3200 3500
Wire Wire Line
	3200 3500 3100 3500
Wire Wire Line
	2100 3500 2500 3500
Wire Wire Line
	3200 3500 3500 3500
Connection ~ 3200 3500
Wire Wire Line
	2650 4100 2000 4100
Connection ~ 2000 4100
Wire Wire Line
	2000 4100 2000 4250
$Comp
L power:+5V #PWR06
U 1 1 5E8007E3
P 3500 1250
F 0 "#PWR06" H 3500 1100 50  0001 C CNN
F 1 "+5V" H 3515 1423 50  0000 C CNN
F 2 "" H 3500 1250 50  0001 C CNN
F 3 "" H 3500 1250 50  0001 C CNN
	1    3500 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	3100 1250 3300 1250
$Comp
L Device:CP CFILT5V1
U 1 1 5E802AEE
P 3300 1400
F 0 "CFILT5V1" H 3418 1446 50  0000 L CNN
F 1 "2200u" H 3418 1355 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D10.0mm_P5.00mm" H 3338 1250 50  0001 C CNN
F 3 "~" H 3300 1400 50  0001 C CNN
	1    3300 1400
	1    0    0    -1  
$EndComp
Connection ~ 3300 1250
Wire Wire Line
	3300 1250 3500 1250
Wire Wire Line
	3300 1550 3300 1650
Wire Wire Line
	3300 1650 2000 1650
Connection ~ 2000 1650
Text Notes 900  900  0    50   ~ 0
For better performance, should add filter caps to all inputs and outputs as per datasheets
$Comp
L Device:CP CSPKCOUP1
U 1 1 5E8228C6
P 9950 5100
F 0 "CSPKCOUP1" H 9832 5146 50  0000 R CNN
F 1 "220u" H 9832 5055 50  0000 R CNN
F 2 "Capacitor_THT:CP_Radial_D10.0mm_P5.00mm" H 9988 4950 50  0001 C CNN
F 3 "~" H 9950 5100 50  0001 C CNN
	1    9950 5100
	-1   0    0    -1  
$EndComp
$Comp
L Device:Speaker LS1
U 1 1 5E823B2D
P 10150 5400
F 0 "LS1" H 10320 5396 50  0000 L CNN
F 1 "Speaker" H 10320 5305 50  0000 L CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x02_P2.54mm_Vertical" H 10150 5200 50  0001 C CNN
F 3 "~" H 10140 5350 50  0001 C CNN
	1    10150 5400
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR07
U 1 1 5E824B11
P 9950 5650
F 0 "#PWR07" H 9950 5400 50  0001 C CNN
F 1 "GND" H 9955 5477 50  0000 C CNN
F 2 "" H 9950 5650 50  0001 C CNN
F 3 "" H 9950 5650 50  0001 C CNN
	1    9950 5650
	1    0    0    -1  
$EndComp
Wire Wire Line
	9950 5250 9950 5400
Wire Wire Line
	9950 5500 9950 5650
$Comp
L Connector:Conn_01x04_Male JFLOW1
U 1 1 5E836135
P 6600 1650
F 0 "JFLOW1" H 6572 1532 50  0000 R CNN
F 1 "Conn_01x04_Male" H 6572 1623 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x04_P2.54mm_Vertical" H 6600 1650 50  0001 C CNN
F 3 "~" H 6600 1650 50  0001 C CNN
	1    6600 1650
	-1   0    0    1   
$EndComp
Text Label 8450 2000 1    50   ~ 0
D12
Text Label 8550 2000 1    50   ~ 0
D11
Text Label 8650 2000 1    50   ~ 0
D10
Text Label 8750 2000 1    50   ~ 0
D9
Text Label 8850 2000 1    50   ~ 0
D8
Text Label 8950 2000 1    50   ~ 0
D7
Text Label 9050 2000 1    50   ~ 0
D6
Text Label 9150 2000 1    50   ~ 0
D5
Text Label 9250 2000 1    50   ~ 0
D4
Text Label 9350 2000 1    50   ~ 0
D3
Text Label 9450 2000 1    50   ~ 0
D2
Text Label 9550 2000 1    50   ~ 0
GND
Text Label 9750 2000 1    50   ~ 0
RX0
Text Label 9850 2000 1    50   ~ 0
TX1
Wire Wire Line
	8450 2050 8450 1850
Wire Wire Line
	8550 2050 8550 1850
Wire Wire Line
	8750 2050 8750 1850
Wire Wire Line
	8850 2050 8850 1850
Wire Wire Line
	8950 2050 8950 1850
Wire Wire Line
	9050 2050 9050 1850
Wire Wire Line
	9550 2050 9550 1850
Wire Wire Line
	9650 2050 9650 1850
Wire Wire Line
	9750 2050 9750 1850
Wire Wire Line
	9850 2050 9850 1850
Text Label 8450 3250 1    50   ~ 0
D13
Text Label 8550 3250 1    50   ~ 0
3V3
Text Label 8650 3250 1    50   ~ 0
REF
Text Label 8750 3250 1    50   ~ 0
A0
Text Label 8850 3250 1    50   ~ 0
A1
Text Label 8950 3250 1    50   ~ 0
A2
Text Label 9050 3250 1    50   ~ 0
A3
Text Label 9150 3250 1    50   ~ 0
A4
Text Label 9250 3250 1    50   ~ 0
A5
Text Label 9350 3250 1    50   ~ 0
A6
Text Label 9450 3250 1    50   ~ 0
A7
Text Label 9550 3250 1    50   ~ 0
+5V
Wire Wire Line
	8450 3050 8450 3250
Wire Wire Line
	8550 3050 8550 3250
Wire Wire Line
	8650 3050 8650 3250
Wire Wire Line
	9350 3050 9350 3250
Wire Wire Line
	9450 3050 9450 3250
Wire Wire Line
	9550 3050 9550 3250
Wire Wire Line
	9650 3050 9650 3250
Text Label 9750 3250 1    50   ~ 0
GND
Text Label 9850 3250 1    50   ~ 0
VIN
Wire Wire Line
	9850 3050 9850 3250
$Comp
L Connector:Conn_01x15_Female ARDUINOD12
U 1 1 5E7F1497
P 9150 2250
F 0 "ARDUINOD12" V 9223 2230 50  0000 C CNN
F 1 "Conn_01x15_Female" V 9314 2230 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x15_P2.54mm_Vertical" H 9150 2250 50  0001 C CNN
F 3 "~" H 9150 2250 50  0001 C CNN
	1    9150 2250
	0    -1   1    0   
$EndComp
$Comp
L Connector:Conn_01x15_Female ARDUINOD13
U 1 1 5E7EAB92
P 9150 2850
F 0 "ARDUINOD13" V 9315 2830 50  0000 C CNN
F 1 "Conn_01x15_Female" V 9224 2830 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x15_P2.54mm_Vertical" H 9150 2850 50  0001 C CNN
F 3 "~" H 9150 2850 50  0001 C CNN
	1    9150 2850
	0    -1   -1   0   
$EndComp
$Comp
L power:+5V #PWR010
U 1 1 5E83E1FF
P 5700 1300
F 0 "#PWR010" H 5700 1150 50  0001 C CNN
F 1 "+5V" H 5715 1473 50  0000 C CNN
F 2 "" H 5700 1300 50  0001 C CNN
F 3 "" H 5700 1300 50  0001 C CNN
	1    5700 1300
	1    0    0    -1  
$EndComp
$Comp
L Device:R RPUSCL1
U 1 1 5E840C9C
P 5950 1450
F 0 "RPUSCL1" H 6020 1496 50  0000 L CNN
F 1 "4K7" H 6020 1405 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 5880 1450 50  0001 C CNN
F 3 "~" H 5950 1450 50  0001 C CNN
	1    5950 1450
	0    -1   -1   0   
$EndComp
$Comp
L Device:R RPUSDA1
U 1 1 5E845F70
P 5950 1750
F 0 "RPUSDA1" H 6020 1796 50  0000 L CNN
F 1 "4K7" H 6020 1705 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 5880 1750 50  0001 C CNN
F 3 "~" H 5950 1750 50  0001 C CNN
	1    5950 1750
	0    1    1    0   
$EndComp
Wire Wire Line
	5700 1300 5700 1450
Wire Wire Line
	5700 1450 5800 1450
Wire Wire Line
	6100 1450 6400 1450
Wire Wire Line
	6100 1750 6400 1750
$Comp
L power:GND #PWR08
U 1 1 5E84BF25
P 5500 1650
F 0 "#PWR08" H 5500 1400 50  0001 C CNN
F 1 "GND" H 5505 1477 50  0000 C CNN
F 2 "" H 5500 1650 50  0001 C CNN
F 3 "" H 5500 1650 50  0001 C CNN
	1    5500 1650
	1    0    0    -1  
$EndComp
Wire Wire Line
	5700 1450 5700 1550
Wire Wire Line
	5700 1750 5800 1750
Connection ~ 5700 1450
Wire Wire Line
	6400 1550 5700 1550
Connection ~ 5700 1550
Wire Wire Line
	5700 1550 5700 1750
Wire Wire Line
	5500 1650 6400 1650
Text Label 6150 1450 0    50   ~ 0
SCL1
Text Label 6150 1750 0    50   ~ 0
SDA1
$Comp
L Connector:Conn_01x04_Male JFLOW2
U 1 1 5E8561B2
P 6600 3050
F 0 "JFLOW2" H 6572 2932 50  0000 R CNN
F 1 "Conn_01x04_Male" H 6572 3023 50  0000 R CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x04_P2.54mm_Vertical" H 6600 3050 50  0001 C CNN
F 3 "~" H 6600 3050 50  0001 C CNN
	1    6600 3050
	-1   0    0    1   
$EndComp
$Comp
L power:+5V #PWR011
U 1 1 5E8561BC
P 5700 2700
F 0 "#PWR011" H 5700 2550 50  0001 C CNN
F 1 "+5V" H 5715 2873 50  0000 C CNN
F 2 "" H 5700 2700 50  0001 C CNN
F 3 "" H 5700 2700 50  0001 C CNN
	1    5700 2700
	1    0    0    -1  
$EndComp
$Comp
L Device:R RPUSCL2
U 1 1 5E8561C6
P 5950 2850
F 0 "RPUSCL2" H 6020 2896 50  0000 L CNN
F 1 "4K7" H 6020 2805 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 5880 2850 50  0001 C CNN
F 3 "~" H 5950 2850 50  0001 C CNN
	1    5950 2850
	0    -1   -1   0   
$EndComp
$Comp
L Device:R RPUSDA2
U 1 1 5E8561D0
P 5950 3150
F 0 "RPUSDA2" H 6020 3196 50  0000 L CNN
F 1 "4K7" H 6020 3105 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal" V 5880 3150 50  0001 C CNN
F 3 "~" H 5950 3150 50  0001 C CNN
	1    5950 3150
	0    1    1    0   
$EndComp
Wire Wire Line
	5700 2700 5700 2850
Wire Wire Line
	5700 2850 5800 2850
Wire Wire Line
	6100 2850 6400 2850
Wire Wire Line
	6100 3150 6400 3150
$Comp
L power:GND #PWR09
U 1 1 5E8561DE
P 5500 3050
F 0 "#PWR09" H 5500 2800 50  0001 C CNN
F 1 "GND" H 5505 2877 50  0000 C CNN
F 2 "" H 5500 3050 50  0001 C CNN
F 3 "" H 5500 3050 50  0001 C CNN
	1    5500 3050
	1    0    0    -1  
$EndComp
Wire Wire Line
	5700 2850 5700 2950
Wire Wire Line
	5700 3150 5800 3150
Connection ~ 5700 2850
Wire Wire Line
	6400 2950 5700 2950
Connection ~ 5700 2950
Wire Wire Line
	5700 2950 5700 3150
Wire Wire Line
	5500 3050 6400 3050
Text Label 6150 2850 0    50   ~ 0
SCL2
Text Label 6150 3150 0    50   ~ 0
SDA2
Wire Wire Line
	9250 3050 9250 3550
Text Label 9250 3550 1    50   ~ 0
SCL1
Wire Wire Line
	9150 3050 9150 3550
Text Label 9150 3550 1    50   ~ 0
SDA1
Text Label 3500 2250 0    50   ~ 0
6V1
Text Label 3500 3500 0    50   ~ 0
6V2
$Comp
L Connector:Conn_01x03_Male JSERVO1
U 1 1 5E883766
P 5600 5050
F 0 "JSERVO1" H 5708 5331 50  0000 C CNN
F 1 "Conn_01x03_Male" H 5708 5240 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x03_P2.54mm_Vertical" H 5600 5050 50  0001 C CNN
F 3 "~" H 5600 5050 50  0001 C CNN
	1    5600 5050
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR02
U 1 1 5E884B69
P 6100 5250
F 0 "#PWR02" H 6100 5000 50  0001 C CNN
F 1 "GND" H 6105 5077 50  0000 C CNN
F 2 "" H 6100 5250 50  0001 C CNN
F 3 "" H 6100 5250 50  0001 C CNN
	1    6100 5250
	1    0    0    -1  
$EndComp
Wire Wire Line
	5800 5050 6200 5050
Wire Wire Line
	5800 5150 6100 5150
Wire Wire Line
	6100 5150 6100 5250
Text Label 6100 4700 1    50   ~ 0
SERVO1
Wire Wire Line
	5800 4950 6100 4950
Wire Wire Line
	6100 4950 6100 4700
$Comp
L Connector:Conn_01x03_Male JSERVO2
U 1 1 5E896BEF
P 5600 6250
F 0 "JSERVO2" H 5708 6531 50  0000 C CNN
F 1 "Conn_01x03_Male" H 5708 6440 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x03_P2.54mm_Vertical" H 5600 6250 50  0001 C CNN
F 3 "~" H 5600 6250 50  0001 C CNN
	1    5600 6250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR03
U 1 1 5E896BF9
P 6100 6450
F 0 "#PWR03" H 6100 6200 50  0001 C CNN
F 1 "GND" H 6105 6277 50  0000 C CNN
F 2 "" H 6100 6450 50  0001 C CNN
F 3 "" H 6100 6450 50  0001 C CNN
	1    6100 6450
	1    0    0    -1  
$EndComp
Wire Wire Line
	5800 6250 6200 6250
Wire Wire Line
	5800 6350 6100 6350
Wire Wire Line
	6100 6350 6100 6450
Text Label 6100 5900 1    50   ~ 0
SERVO2
Wire Wire Line
	5800 6150 6100 6150
Wire Wire Line
	6100 6150 6100 5900
Wire Wire Line
	9250 1550 9250 2050
Wire Wire Line
	9150 1550 9150 2050
Text Label 9250 1800 1    50   ~ 0
SERVO1
Text Label 9150 1800 1    50   ~ 0
SERVO2
NoConn ~ 9650 3250
NoConn ~ 9850 3250
Wire Wire Line
	9750 3050 9750 3250
NoConn ~ 9450 3250
NoConn ~ 9350 3250
NoConn ~ 8650 3250
NoConn ~ 8550 3250
NoConn ~ 8450 3250
NoConn ~ 8450 1850
NoConn ~ 8550 1850
NoConn ~ 8750 1850
NoConn ~ 8850 1850
NoConn ~ 8950 1850
NoConn ~ 9050 1850
NoConn ~ 9750 1850
NoConn ~ 9850 1850
NoConn ~ 9650 1850
Text Label 9050 3550 1    50   ~ 0
SCL2
Text Label 8950 3550 1    50   ~ 0
SDA2
Wire Wire Line
	9950 4950 9950 4800
$Comp
L Connector:Conn_01x03_Male JPRESSURE1_13_1
U 1 1 5E8A0C71
P 2900 6000
F 0 "JPRESSURE1_13_1" H 3250 6300 50  0000 R CNN
F 1 "Conn_01x03_Male" H 3200 6200 50  0000 R CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x03_P2.54mm_Vertical" H 2900 6000 50  0001 C CNN
F 3 "~" H 2900 6000 50  0001 C CNN
	1    2900 6000
	1    0    0    -1  
$EndComp
Wire Wire Line
	3350 5900 3100 5900
NoConn ~ 3100 6000
NoConn ~ 2050 6100
NoConn ~ 2050 6000
$Comp
L Connector:Conn_01x03_Male JPRESSURE1_46_1
U 1 1 5E8A2042
P 2250 6000
F 0 "JPRESSURE1_46_1" H 2350 6300 50  0000 C CNN
F 1 "Conn_01x03_Male" H 2350 6200 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x03_P2.54mm_Vertical" H 2250 6000 50  0001 C CNN
F 3 "~" H 2250 6000 50  0001 C CNN
	1    2250 6000
	-1   0    0    -1  
$EndComp
Wire Wire Line
	3100 6100 3350 6100
$Comp
L Connector:Conn_01x03_Male JPRESSURE1
U 1 1 5E9A3DA6
P 8750 5100
F 0 "JPRESSURE1" H 8850 5400 50  0000 C CNN
F 1 "Conn_01x03_Male" H 8850 5300 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x03_P2.54mm_Vertical" H 8750 5100 50  0001 C CNN
F 3 "~" H 8750 5100 50  0001 C CNN
	1    8750 5100
	-1   0    0    -1  
$EndComp
Wire Wire Line
	8550 5000 8050 5000
Wire Wire Line
	8550 5100 8050 5100
Wire Wire Line
	8550 5200 8050 5200
Text Label 8050 5000 0    50   ~ 0
GND
Wire Wire Line
	8750 3050 8750 3750
Wire Wire Line
	8850 3050 8850 3750
Text Label 8750 3750 1    50   ~ 0
PRESSURE1
Text Label 8850 3750 1    50   ~ 0
PRESSURE2
$Comp
L Connector:Conn_01x02_Male JPRESSURE1_BO13_1
U 1 1 5E9DC89F
P 3550 5900
F 0 "JPRESSURE1_BO13_1" H 3522 5874 50  0000 R CNN
F 1 "Conn_01x02_Male" H 3522 5783 50  0000 R CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x02_P2.54mm_Vertical" H 3550 5900 50  0001 C CNN
F 3 "~" H 3550 5900 50  0001 C CNN
	1    3550 5900
	-1   0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x01_Male JPRESSURE1_BO4_1
U 1 1 5E9DE12F
P 1300 5900
F 0 "JPRESSURE1_BO4_1" H 1408 6081 50  0000 C CNN
F 1 "Conn_01x01_Male" H 1408 5990 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x01_P2.54mm_Vertical" H 1300 5900 50  0001 C CNN
F 3 "~" H 1300 5900 50  0001 C CNN
	1    1300 5900
	1    0    0    -1  
$EndComp
Wire Wire Line
	1500 5900 2050 5900
Wire Wire Line
	3350 6100 3350 6000
$Comp
L Connector:Conn_01x03_Male JPRESSURE2_13_1
U 1 1 5EA099C7
P 2900 6600
F 0 "JPRESSURE2_13_1" H 3250 6900 50  0000 R CNN
F 1 "Conn_01x03_Male" H 3200 6800 50  0000 R CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x03_P2.54mm_Vertical" H 2900 6600 50  0001 C CNN
F 3 "~" H 2900 6600 50  0001 C CNN
	1    2900 6600
	1    0    0    -1  
$EndComp
Wire Wire Line
	3350 6500 3100 6500
NoConn ~ 3100 6600
NoConn ~ 2050 6700
NoConn ~ 2050 6600
$Comp
L Connector:Conn_01x03_Male JPRESSURE2_46_1
U 1 1 5EA099D5
P 2250 6600
F 0 "JPRESSURE2_46_1" H 2350 6900 50  0000 C CNN
F 1 "Conn_01x03_Male" H 2350 6800 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x03_P2.54mm_Vertical" H 2250 6600 50  0001 C CNN
F 3 "~" H 2250 6600 50  0001 C CNN
	1    2250 6600
	-1   0    0    -1  
$EndComp
Wire Wire Line
	3100 6700 3350 6700
$Comp
L Connector:Conn_01x03_Male JPRESSURE2
U 1 1 5EA099E0
P 8750 5700
F 0 "JPRESSURE2" H 8850 6000 50  0000 C CNN
F 1 "Conn_01x03_Male" H 8850 5900 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x03_P2.54mm_Vertical" H 8750 5700 50  0001 C CNN
F 3 "~" H 8750 5700 50  0001 C CNN
	1    8750 5700
	-1   0    0    -1  
$EndComp
Wire Wire Line
	8550 5600 8050 5600
Wire Wire Line
	8550 5700 8050 5700
Wire Wire Line
	8550 5800 8050 5800
Text Label 8050 5600 0    50   ~ 0
GND
$Comp
L Connector:Conn_01x02_Male JPRESSURE2_BO13_1
U 1 1 5EA099F0
P 3550 6500
F 0 "JPRESSURE2_BO13_1" H 3522 6474 50  0000 R CNN
F 1 "Conn_01x02_Male" H 3522 6383 50  0000 R CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x02_P2.54mm_Vertical" H 3550 6500 50  0001 C CNN
F 3 "~" H 3550 6500 50  0001 C CNN
	1    3550 6500
	-1   0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x01_Male JPRESSURE2_BO4_1
U 1 1 5EA099FA
P 1300 6500
F 0 "JPRESSURE2_BO4_1" H 1408 6681 50  0000 C CNN
F 1 "Conn_01x01_Male" H 1408 6590 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x01_P2.54mm_Vertical" H 1300 6500 50  0001 C CNN
F 3 "~" H 1300 6500 50  0001 C CNN
	1    1300 6500
	1    0    0    -1  
$EndComp
Wire Wire Line
	1500 6500 2050 6500
Wire Wire Line
	3350 6700 3350 6600
Text Label 8050 5200 0    50   ~ 0
+5V
Text Label 8050 5800 0    50   ~ 0
+5V
Text Label 8050 5100 0    50   ~ 0
PRESSURE1
Text Label 8050 5700 0    50   ~ 0
PRESSURE2
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 5EA2BBEE
P 1800 4250
F 0 "#FLG0101" H 1800 4325 50  0001 C CNN
F 1 "PWR_FLAG" H 1800 4423 50  0000 C CNN
F 2 "" H 1800 4250 50  0001 C CNN
F 3 "~" H 1800 4250 50  0001 C CNN
	1    1800 4250
	1    0    0    -1  
$EndComp
Wire Wire Line
	1800 4250 2000 4250
Connection ~ 2000 4250
Wire Wire Line
	2000 4250 2000 4400
Wire Wire Line
	2100 1250 2100 2250
Wire Wire Line
	2500 2250 2100 2250
Connection ~ 2100 2250
Wire Wire Line
	2100 2250 2100 3500
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 5EA32CE9
P 1900 1250
F 0 "#FLG0102" H 1900 1325 50  0001 C CNN
F 1 "PWR_FLAG" H 1900 1423 50  0000 C CNN
F 2 "" H 1900 1250 50  0001 C CNN
F 3 "~" H 1900 1250 50  0001 C CNN
	1    1900 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	1900 1250 2100 1250
Text Label 6200 5050 0    50   ~ 0
6V1
Text Label 6200 6250 0    50   ~ 0
6V2
Connection ~ 2000 2900
Wire Wire Line
	2000 2900 2000 4100
Wire Wire Line
	2000 1650 2000 2900
NoConn ~ 2950 2900
Wire Wire Line
	2800 2650 2800 2750
Connection ~ 2800 2650
Wire Wire Line
	2800 2650 3200 2650
Wire Wire Line
	2800 2550 2800 2650
Wire Wire Line
	2650 2900 2000 2900
$Comp
L Device:R_POT_TRIM RADJ6V1
U 1 1 5E7F226A
P 2800 2900
F 0 "RADJ6V1" V 2685 2900 50  0000 C CNN
F 1 "R_POT_TRIM" V 2594 2900 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Piher_PT-10-V10_Vertical" H 2800 2900 50  0001 C CNN
F 3 "~" H 2800 2900 50  0001 C CNN
	1    2800 2900
	0    -1   -1   0   
$EndComp
Wire Wire Line
	3200 3900 2800 3900
Connection ~ 2800 3900
Wire Wire Line
	2800 3900 2800 3800
NoConn ~ 2950 4100
Wire Wire Line
	8950 3050 8950 3550
Wire Wire Line
	9050 3050 9050 3550
Wire Wire Line
	9350 1850 9350 2050
Wire Wire Line
	9450 1850 9450 2050
NoConn ~ 9350 1850
NoConn ~ 9450 1850
Wire Wire Line
	8650 1550 8650 2050
Text Label 8650 1800 1    50   ~ 0
SPEAKER
Text Label 9950 4800 0    50   ~ 0
SPEAKER
$Comp
L Switch:SW_SPST SWPOWER1
U 1 1 5E844065
P 1450 1250
F 0 "SWPOWER1" H 1450 1485 50  0000 C CNN
F 1 "SW_SPST" H 1450 1394 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x02_P2.54mm_Vertical" H 1450 1250 50  0001 C CNN
F 3 "~" H 1450 1250 50  0001 C CNN
	1    1450 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	950  1250 1250 1250
Wire Wire Line
	1650 1250 1900 1250
Connection ~ 1900 1250
Text Notes 3750 2250 0    50   ~ 0
6V Rail for servo 1
Text Notes 3750 3500 0    50   ~ 0
6V Rail for servo 2
Text Notes 5250 950  0    50   ~ 0
Flow sensor 1 - Honeywell HAFUHH0300L4AXT
Text Notes 5250 2400 0    50   ~ 0
Flow sensor 2 - Honeywell HAFUHH0300L4AXT
Text Notes 1500 5450 0    50   ~ 0
Pressure sensor breakout PCBs - Honeywell ABPDJJT001PGAA5 x2
Text Notes 7750 4600 0    50   ~ 0
Pressure sensor breakout board connectors
Text Notes 5950 4350 0    50   ~ 0
Servo 1
Text Notes 5950 5600 0    50   ~ 0
Servo 2
Text Notes 9850 4600 0    50   ~ 0
Alarm speaker
$EndSCHEMATC
