// Inputs:
// -Inhalation pressure sensor: analog input A0
// -Exhalation pressure sensor: analog input A1
// -Inhalation flow sensor: hardware I2C on pins A4/A5
// -Exhalation flow sensor: software I2C on pins D2/D3

// Outputs:
// -speaker (for alarm): D10
// -proportional O2 valve: servo on D4
// -proportional air valve: servo on D5

#define VIRTUAL_INPUTS 1

#if !VIRTUAL_INPUTS
#include <Wire.h>
#include <SoftwareWire.h>
#else
struct EmptyPlaceholderType {};
#endif

#include <Servo.h>

/////////////////////////////
// Global hardware and software configuration
/////////////////////////////

// Beware: some pins may not be able to assume all functions
const int PIN_SOFTWARE_I2C_SDA = A2;
const int PIN_SOFTWARE_I2C_SCL = A3;

const int PIN_INHALE_PRESSURE_SENSOR = A0;
const int PIN_EXHALE_PRESSURE_SENSOR = A1;

const int PIN_ALARM_SPEAKER = 10;

const int PIN_O2_VALVE = 4;
const int PIN_AIR_VALVE = 5;

const int kMachineStateSendIntervalMs = 100;

float globalDebugFloat1;
float globalDebugFloat2;
float globalDebugFloat3;
float globalDebugFloat4;

/////////////////////////////
// General utilities
/////////////////////////////

void Blink(long ms = 250)
{
    digitalWrite(13, HIGH);
    delay(ms);
    digitalWrite(13, LOW);
    delay(ms);
}

#define assert(x, msg) if (!(x)) { Halt(__LINE__, msg); }
#define verify(x, msg) assert(x, msg)
#define HALT() Halt(__LINE__, "Halt")

template <class T>
void Halt(int line, const T* msg)
{
    Serial.print(F("Halt: L"));
    Serial.println(line);
    Serial.println(msg);
    Serial.flush();
    pinMode(13, OUTPUT);
    for (;;)
    {
        Blink(250);
    }
}

#define ARRAY_COUNT(x) (static_cast<int>(sizeof(x) / sizeof(x[0])))

template <class T>
void Zero(T& t)
{
    memset(&t, 0, sizeof(t));
}

float Clamp01(float v)
{
    return min(max(v, 0.0f), 1.0f);
}

float Clamp(float v, float minValue, float maxValue)
{
    return min(max(v, minValue), maxValue);
}

float Lerp(float a, float b, float t)
{
    return a + (b - a) * t;
}

/////////////////////////////
// Error tracking
/////////////////////////////

namespace Error
{
    enum Type
    {
        None = 0,
        InvalidUIInput = 1,
        UnimplementedFeature = 2,
    };
}

long gErrorMask = 0;

void RaiseError(int error) // @LAME: becaus Arduino pre-processing is a little broken for forward declarations we can't receive in Error:Type as an argument here
{
    gErrorMask |= (1 << (error - 1));
}

template<typename T>
void ValidateUIState(T& t, int minT, int maxT)
{
    if (t < minT)
    {
        RaiseError(Error::InvalidUIInput);
        t = minT;
    }
    if (t > maxT)
    {
        RaiseError(Error::InvalidUIInput);
        t = maxT;
    }
}

template<typename T>
void ValidateUIState(T& t, float minT, float maxT)
{
    if (t < minT)
    {
        RaiseError(Error::InvalidUIInput);
        t = minT;
    }
    if (t > maxT)
    {
        RaiseError(Error::InvalidUIInput);
        t = maxT;
    }
}

/////////////////////////////
// Event tracking
/////////////////////////////

class EventFrequencyTracker
{
public:
    EventFrequencyTracker(long windowTimeMs = 500, float rateFilterRate = 0.5f)
        : _windowTimeMs(windowTimeMs)
        , _rateFilterRate(rateFilterRate)
    {
    }

    void AddEventCount(float count)
    {
        _currentEventCount += count;
    }

    void Update()
    {
        long nowMs = millis();
        long msSinceLastWindowShift = nowMs - _lastWindowStartMs;
        if (msSinceLastWindowShift >= _windowTimeMs)
        {
            float instantRate = _currentEventCount / msSinceLastWindowShift * 1000.0f;

            if (_rate < 0.0f)
            {
                _rate = instantRate;
            }
            else
            {
                _rate = Lerp(_rate, instantRate, _rateFilterRate);
            }

            _currentEventCount = 0.0f;
            _lastWindowStartMs = nowMs;
        }
    }

    bool HasRate()
    {
        return _rate >= 0.0f;
    }

    float GetRate()
    {
        return _rate;
    }

private:
    long _windowTimeMs = 0;
    float _currentEventCount = 0.0f;
    long _lastWindowStartMs = 0;
    float _rate = -1.0f;
    float _rateFilterRate = 1.0f;
};

EventFrequencyTracker gReceiveRawUIStateRate;
EventFrequencyTracker gReceiveValidUIStateRate;
EventFrequencyTracker gSendMachineStateRate;

/////////////////////////////
// Printing and formatting
/////////////////////////////

#define DEFAULT_PRINT (&Serial)
#define DEFAULT_FLOAT_DECIMALS 9

void Ln(Print* p = DEFAULT_PRINT)
{
    p->println("");
}

void ClearScreen(Print* p = DEFAULT_PRINT)
{
    p->print("\x1B[2J");
}

void MoveCursor(int x, int y, Print* p = DEFAULT_PRINT)
{
    p->print("\x1B[");
    p->print(y + 1);
    p->print(";");
    p->print(x + 1);
    p->print("H");
}

void Space(Print* p = DEFAULT_PRINT)
{
    p->print(" ");
}

void Cls(Print* p = DEFAULT_PRINT)
{
    p->print(char(27));
    p->print("[2J");
}

void PrintFloat(float f, int decimals = DEFAULT_FLOAT_DECIMALS, Print* p = DEFAULT_PRINT)
{
    if (f < 0)
    {
        p->print("-");
        f = -f;
    }
    else
    {
        p->print(" ");
    }

    int b = int(f);
    p->print(b);
    p->print(".");
    f -= b;
    for (int i = 0; i < decimals; ++i)
    {
        f *= 10.0f;
        int a = int(f);
        p->print(a);
        f -= a;
    }
}

void PrintHex16(uint16_t h, Print* p = DEFAULT_PRINT)
{
    static char const* hex = "0123456789ABCDEF";
    p->print(hex[(h & 0xF000) >> 12]);
    p->print(hex[(h & 0x0F00) >> 8]);
    p->print(hex[(h & 0x00F0) >> 4]);
    p->print(hex[(h & 0x000F) >> 0]);
}

void PrintHex32(uint32_t h, Print* p = DEFAULT_PRINT)
{
    static char const* hex = "0123456789ABCDEF";
    p->print(hex[(h & 0xF0000000) >> 28]);
    p->print(hex[(h & 0x0F000000) >> 24]);
    p->print(hex[(h & 0x00F00000) >> 20]);
    p->print(hex[(h & 0x000F0000) >> 16]);
    p->print(hex[(h & 0x0000F000) >> 12]);
    p->print(hex[(h & 0x00000F00) >> 8]);
    p->print(hex[(h & 0x000000F0) >> 4]);
    p->print(hex[(h & 0x0000000F) >> 0]);
}

void PrintStringChar(char const* s, char c, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": ");
    p->print(c);
}

void PrintStringInt(const __FlashStringHelper *s, int v, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": ");
    p->print(v);
}

void PrintStringInt(char const* s, int v, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": ");
    p->print(v);
}

void PrintStringLong(const __FlashStringHelper *s, long v, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": ");
    p->print(v);
}

void PrintStringLong(char const* s, long v, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": ");
    p->print(v);
}

void PrintStringHex32(const __FlashStringHelper *s, uint32_t v, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": 0x");
    PrintHex32(v);
}

void PrintStringHex32(char const* s, uint32_t v, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    p->print(": 0x");
    PrintHex32(v);
}

void PrintFormattedFloat(float f, int decimals = DEFAULT_FLOAT_DECIMALS, Print* p = DEFAULT_PRINT)
{
    p->print(": ");
    // if (f < 10000.0f)
    // {
    //     p->print(" ");
    // }
    // if (f < 1000.0f)
    // {
    //     p->print(" ");
    // }
    if (f < 100.0f)
    {
        p->print(" ");
    }
    if (f < 10.0f)
    {
        p->print(" ");
    }
    PrintFloat(f, decimals);
}

void PrintStringFloat(const __FlashStringHelper *s, float f, int decimals = DEFAULT_FLOAT_DECIMALS, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    PrintFormattedFloat(f, decimals, p);
}

void PrintStringFloat(char const* s, float f, int decimals = DEFAULT_FLOAT_DECIMALS, Print* p = DEFAULT_PRINT)
{
    p->print(s);
    PrintFormattedFloat(f, decimals, p);
}

/////////////////////////////
// Button input
/////////////////////////////

class PushButton
{
public:
    PushButton(int pin, bool activeLow = true)
        : _pin(pin)
        , _debounceStart(0)
        , _activeLow(activeLow)
    {
        pinMode(_pin, INPUT_PULLUP);
        _lastValue = _activeLow ? 1 : 0;
        _lastHeld = false;
    }

    void Update()
    {
        _justPressed = false;
        _justRelease = false;
        _justHeld = false;

        unsigned long nowMs = millis();

        if (nowMs < _debounceStart + kDebounceMs)
        {
            return;
        }

        int buttonValue = digitalRead(_pin);
        int const ACTIVE = _activeLow ? 0 : 1;
        int const INACTIVE = 1 - ACTIVE;
        if ((_lastValue == INACTIVE) && (buttonValue == ACTIVE))
        {
            _debounceStart = nowMs;
            _justPressed = true;
            _lastHeld = false;
        }
        else if ((_lastValue == ACTIVE) && (buttonValue == INACTIVE))
        {
            _debounceStart = nowMs;
            _justRelease = true;
        }

        if ((buttonValue == ACTIVE) && !_lastHeld && (nowMs > _debounceStart + kHeldMs))
        {
            _justHeld = true;
            _lastHeld = true;
        }

        _lastValue = buttonValue;
    }

    bool IsPressed() const { return _lastValue == (_activeLow ? 0 : 1); }
    bool JustPressed() const { return _justPressed; }
    bool IsHeld() const { return IsPressed() && _lastHeld; }
    bool JustHeld() const { return _justHeld; }
    bool JustReleased() const { return _justRelease; }
    bool JustReleasedAndWasHeld() const { return _justRelease && _lastHeld; }
    bool JustReleasedAndWasNotHeld() const { return _justRelease && !_lastHeld; }

    void WaitForPress()
    {
        for (; !JustPressed(); Update());
        Update();
    }

private:
    static const int kDebounceMs = 25;
    static const int kHeldMs = 800;

    char _pin;
    char _lastValue = 0;
    bool  _lastHeld = false;
    unsigned long _debounceStart = 0;
    bool _activeLow = false;
    bool _justPressed = false;
    bool _justHeld = false;
    bool _justRelease = false;
};

/////////////////////////////
// Sound
/////////////////////////////

class NoiseMaker
{
public:
    NoiseMaker(int pinNumber)
        : _pin(pinNumber)
        , _enabled(true)
    {
        noTone(_pin);
        _lastMs = 0;
        
        _pitch = 440.0f;
        _stepsLeft = 0;
        _stepLengthMs = 0;
        _pitchNudge = 1.0f;
        
        _minPitch = 0.0f;
        _pitchBump = 1.0f;
    }

    void Tick()
    {
        _pitch = 700.0f;
        _stepsLeft = 5;
        _stepLengthMs = 5;
        _pitchNudge = 1.2f;
        
        _minPitch = 0.0f;
        _pitchBump = 1.0f;
    }

    void Tock()
    {
        _pitch = 700.0f * 1.3f;
        _stepsLeft = 5;
        _stepLengthMs = 5;
        _pitchNudge = 1.2f * 1.3f;
        
        _minPitch = 0.0f;
        _pitchBump = 1.0f;
    }

    void Bleep()
    {
        _pitch = 500.0f;
        _stepsLeft = 4;
        _stepLengthMs = 20;
        _pitchNudge = 1.15f;
        
        _minPitch = 0.0f;
        _pitchBump = 1.0f;
    }

    void Bloop()
    {
        _pitch = 500.0f * 1.3f;
        _stepsLeft = 4;
        _stepLengthMs = 20;
        _pitchNudge = 1.15f * 1.3f;
        
        _minPitch = 0.0f;
        _pitchBump = 1.0f;
    }

    void BombDrop()
    {
        _minPitch = 130.0f;
        _pitchNudge = 0.63f;
        _pitchBump = 2.5f;
        _pitch = _minPitch * _pitchBump;
        _stepsLeft = 120;
        _stepLengthMs = 10;
    }

    void Laser()
    {
        _minPitch = 500.0f;
        _pitchNudge = 0.71f;
        _pitchBump = 4.1f;
        _pitch = _minPitch * _pitchBump;
        _stepsLeft = 138;
        _stepLengthMs = 4;
    }

    void Spring()
    {
        _minPitch = 400.0f;
        _pitchNudge = 0.71f;
        _pitchBump = 4.1f;
        _pitch = _minPitch * _pitchBump;
        _stepsLeft = 38;
        _stepLengthMs = 28;
    }

    bool IsEnabled()
    {
        return _enabled;
    }

    void SetEnabled(bool enabled)
    {
        _enabled = enabled;
    }

    void Update()
    {
        long nowMs = millis();

        if (!_enabled)
        {
            _stepsLeft = 0;
        }

        if (_stepsLeft > 0)
        {
            if ((_stepLengthMs > 0) && (nowMs - _lastMs >= _stepLengthMs))
            {
                _pitch *= _pitchNudge;
                if (_pitch < _minPitch)
                {
                    _pitch *= _pitchBump;
                }

                _lastMs = nowMs;

                --_stepsLeft;
            }
        }

        if (_stepsLeft > 0)
        {
            // PrintStringInt("p", _pitch); Ln();
            tone(_pin, static_cast<int>(_pitch));
        }
        else
        {
            // Serial.print("N"); Ln();
            noTone(_pin);
        }
    }

private:
    int _pin = 0;
    bool _enabled = false;

    long _lastMs = 0;

    int _stepLengthMs = 0;
    int _stepsLeft = 0;

    float _pitch = 0.0f;
    float _pitchNudge = 0.0f;

    float _minPitch = 0.0f;
    float _pitchBump = 0.0f;
};

/////////////////////////////
// Pressure sensor input
/////////////////////////////

class PressureSensor
{
public:
    PressureSensor(int pin)
        : _pin(pin)
    {
        pinMode(_pin, INPUT);
    }

    float GetPressurePsi() const
    {
#if !VIRTUAL_INPUTS
        int rawValue = analogRead(_pin);
        float v01 = rawValue / 1023.0f;
        return UnitSampleToPsi(v01);
#else
        return _virtualPressureReading;
#endif
    }

    float GetPressureCmH2O() const
    {
        return GetPressurePsi() * kPsiToCmH2O;
    }

#if VIRTUAL_INPUTS
    void SetVirtualServoOpening(float o2Opening, float airOpening, float deltaSeconds)
    {
        const float kInputPsi = 1.0f;
        float totalPsi = o2Opening * kInputPsi + airOpening * kInputPsi;

        _totalSeconds += deltaSeconds;
        totalPsi *= 1.0f + sinf(_totalSeconds * 2.0f) * 0.4f;

        _virtualPressureReading = LowPassFilter(_virtualPressureReading, totalPsi, 0.0000001f, deltaSeconds);
    }
#endif

private:
    const float kPsiToCmH2O = 70.307f;

    float UnitSampleToPsi(float v01) const
    {
        const float kMinPsi = 0.0f;
        const float kMaxPsi = 1.0f;

        return ((v01 - 0.1f) * (kMaxPsi - kMinPsi) / 0.8f) + kMinPsi;
    }

    char _pin;

#if VIRTUAL_INPUTS
    float _virtualPressureReading = 0.0f;
    float _totalSeconds = 0.0f;
#endif
};

/////////////////////////////
// Flow sensor input
/////////////////////////////

template <class I2C>
class FlowSensor
{
public:
    FlowSensor(I2C& i2c)
        : _i2c(i2c)
    {
#if !VIRTUAL_INPUTS
        EnsureDeviceIsResponsive();
        

        // Discard the first two bytes, which may or may not be the serial depending on how long it's been since boot
        ReadTwoBytes();
        CommandDelay();
        ReadTwoBytes();
        CommandDelay();
        

        // Request serial number
        _i2c.beginTransmission(kI2cAddress);
        _i2c.write(0x01);
        _i2c.endTransmission();
        CommandDelay();

        // Read serial number
        uint16_t serialHigh = ReadTwoBytes();
        CommandDelay();
        uint16_t serialLow = ReadTwoBytes();
        CommandDelay();

        _serial = (uint32_t(serialHigh) << 16) | serialLow;
#else
        _serial = 0x12345678;
#endif
    }

    float GetFlowSlpm()
    {
        UpdateIfRequired();
        return _flowRate;
    }

    float GetFlowLps()
    {
        return GetFlowSlpm() / 60.0f;
    }

    uint32_t GetSerial() const
    {
        return _serial;
    }

#if VIRTUAL_INPUTS
    void SetVirtualLungFlow(float flow, bool isInhalationSensor)
    {
        _flowRate = (isInhalationSensor ? max(flow, 0.0f) : max(-flow, 0.0f));
    }
#endif

private:
    const int kI2cAddress = 0x49;
    const float kMaxSlpm = 15.0f;

    void EnsureDeviceIsResponsive()
    {
#if !VIRTUAL_INPUTS
        _i2c.beginTransmission(kI2cAddress);
        uint8_t error =_i2c.endTransmission();
        assert(error == 0, F("No device found at requisite I2C address"));
        CommandDelay();
#endif
    }

    void UpdateIfRequired()
    {
        long nowMs = millis();
        if (nowMs - _lastUpdateMs >= 1)
        {
#if !VIRTUAL_INPUTS
            uint16_t rawValue = ReadTwoBytes();
            _flowRate = kMaxSlpm * ((float(rawValue) / 16384) - 0.1f) / 0.8f;
#endif

            _lastUpdateMs = nowMs;
        }
    }

    void CommandDelay()
    {
        delay(10);
    }

#if !VIRTUAL_INPUTS
    uint16_t ReadTwoBytes()
    {
        _i2c.requestFrom(kI2cAddress, 2);
        
        uint8_t buf[2];
        assert(_i2c.available(), F("Expected first I2C byte"));
        buf[0] = _i2c.read();

        assert(_i2c.available(), F("Expected second I2C byte"));
        buf[1] = _i2c.read();

        assert(!_i2c.available(), F("Expected no more than two I2C bytes"));

        return (uint16_t(buf[0]) << 8) | buf[1];
    }
#endif

    I2C& _i2c;

    uint32_t _serial = 0;
    
    long _lastUpdateMs = 0;

    float _flowRate = 0.0f;
};

/////////////////////////////
// Humidity and temperature sensor
/////////////////////////////

template <class I2C>
class HumidityTemperatureSensor
{
public:
    HumidityTemperatureSensor(I2C& i2c)
        : _i2c(i2c)
    {
    }

    // std::tuple/tie not available on gcc's current toolchain
    float GetHumidity01()
    {
        UpdateIfRequired();

        return _humidity;
    }

    float GetTemperature()
    {
        UpdateIfRequired();

        return _temperature;
    }

private:
    const int kI2cAddress = 0x27;

    void EnsureDeviceIsResponsive()
    {
        _i2c.beginTransmission(kI2cAddress);
        uint8_t error =_i2c.endTransmission();
        assert(error == 0, F("No device found at requisite I2C address"));
        delay(10);
    }

    void UpdateIfRequired()
    {
        long nowMs = millis();
        if (nowMs - _lastUpdateMs >= 1)
        {
            _i2c.beginTransmission(kI2cAddress);
            _i2c.endTransmission();
            uint32_t rawValue = ReadFourBytes();

            // PrintStringHex32("HTRV", rawValue); DEFAULT_PRINT->print(" ");

            // uint8_t status = rawValue >> 30;
            uint16_t mask14 = (1 << 14) - 1;
            uint16_t rawHumidity = (rawValue >> 16) & mask14;
            uint16_t rawTemperature = (rawValue >> 2) & mask14;

            const uint16_t denominator = (1 << 14) - 2;
            _humidity = float(rawHumidity) / denominator;
            _temperature = ((float(rawTemperature) / denominator) * 165) - 40;

            _lastUpdateMs = nowMs;
        }
    }

    uint32_t ReadFourBytes()
    {
        _i2c.requestFrom(kI2cAddress, 4);
        
        uint8_t buf[4];
        assert(_i2c.available(), F("Expected first I2C byte"));
        buf[0] = _i2c.read();

        assert(_i2c.available(), F("Expected second I2C byte"));
        buf[1] = _i2c.read();

        assert(_i2c.available(), F("Expected third I2C byte"));
        buf[2] = _i2c.read();

        assert(_i2c.available(), F("Expected fourth I2C byte"));
        buf[3] = _i2c.read();

        assert(!_i2c.available(), F("Expected no more than four I2C bytes"));

        return (uint32_t(buf[0]) << 24)
        | (uint32_t(buf[1]) << 16)
        | (uint32_t(buf[2]) << 8)
        | buf[3];
    }

    I2C& _i2c;

    long _lastUpdateMs = 0;

    float _humidity = 0.0f;
    float _temperature = 0.0f;
};

/////////////////////////////
// Proportional valve output
/////////////////////////////

class ProportionalValve
{
public:
	ProportionalValve(int pin, float closedAngle, float openAngle)
        : _closedAngle(closedAngle)
        , _openAngle(openAngle)
	{
		_servo.attach(pin, 550, 2300);
	}

	void SetPosition01(float position01)
	{
        //@TODO: map to physical valve response
        _targetPosition = Clamp01(position01);
        float angleFloat = Lerp(_closedAngle, _openAngle, _targetPosition);
		int angle = static_cast<int>(angleFloat);
		_servo.write(angle);
	}

#if VIRTUAL_INPUTS
    void Update(float deltaSeconds)
    {
        _position = LinearApproach(_position, _targetPosition, 5.0f, deltaSeconds);
    }
    
    float GetPosition01() const
    {
        return _position;
    }
#endif

private:
	Servo _servo;

    float _closedAngle = 0.0f;
    float _openAngle = 0.0f;

    float _targetPosition = 0.0f;

#if VIRTUAL_INPUTS
    float _position = 0.0f;
#endif
};

/////////////////////////////
// Serialization and state
/////////////////////////////

namespace ControlMode
{
    enum Type
    {
        Off = 0,
        PressureControl = 1,
        VolumeControl = 2
    };
}

namespace TriggerMode
{
    enum Type
    {
        Off = 0,
        Timed = 1,
        PatientEffort = 2
    };
}

// This structure is designed to be zeroable in memory. The zero state should result in null operation (e.g. both valves closed, no triggering.)
struct __attribute__((packed)) UIState
{
    float FiO2;                                     // 0-1 ratio: 1.0 is 100% O2
    
    uint8_t ControlMode;                            // see ControlMode

    // If pressure control mode:
    float PressureControlInspiratoryPressure;       // cmH2O

    // If volume control mode:
    // float VolumeControlMaxPressure;                 // cmH2O
    // float VolumeControlTidalVolume;                 // L

    float Peep;                                     // cmH2O

    float InspirationTime;                          // s

    float InspirationFilterRate;                    // IIR filter rate - how much error remains after one second: 0.1 means 10% of error remains after one second
    float ExpirationFilterRate;                     // IIR filter rate

    uint8_t TriggerMode;                            // see TriggerMode

    int TimerTriggerBreathsPerMin;                  // breaths/min

    // int PatientEffortTriggerMinBreathsPerMin;       // breaths/min
    // float PatientEffortTriggerLitersPerMin;         // L/min

    uint8_t BreathManuallyTriggered;                // 1: yes, 0:no

    void Validate()
    {
        const float kMaxPressure = 40.0f;
        const int kMaxBreathsPerMinute = 30;

        ValidateUIState(FiO2, 0.21f, 1.0f);
        
        ValidateUIState(ControlMode, 0, 2);
        
        ValidateUIState(PressureControlInspiratoryPressure, 0.0f, kMaxPressure);
        
        // ValidateUIState(VolumeControlMaxPressure, 0.0f, kMaxPressure);
        // ValidateUIState(VolumeControlTidalVolume, 0.0f, 1.0f);
        
        ValidateUIState(Peep, 0.0f, kMaxPressure);
        
        ValidateUIState(InspirationTime, 0.5f, 3.0f);
        
        ValidateUIState(InspirationFilterRate, 0.0f, 0.5f);
        ValidateUIState(ExpirationFilterRate, 0.0f, 0.5f);
        
        ValidateUIState(TriggerMode, 0, 2);
        
        ValidateUIState(TimerTriggerBreathsPerMin, 5, kMaxBreathsPerMinute);
        
        // ValidateUIState(PatientEffortTriggerMinBreathsPerMin, 0, kMaxBreathsPerMinute);
        // ValidateUIState(PatientEffortTriggerLitersPerMin, 0.0f, 5.0f);
    }
};

struct __attribute__((packed)) MachineState
{
    float InstantInhalationPressure;                // cmH2O
    float InstantInhalationFlow;                    // L/min

    float InstantExhalationPressure;                // cmH2O
    float InstantExhalationFlow;                    // L/min

    float InstantO2ValveOpening;                    // 0-1
    float InstantAirValveOpening;                   // 0-1

    float InstantTotalVolume;                       // L

    float InstantTotalFlowLitersPerMin;             // L/min

    float MinuteExhalationLitersPerMin;            // L/min
    float RespiratoryFrequencyBreathsPerMin;        // breaths/min

    float InhalationTidalVolume;                    // L
    float ExhalationTidalVolume;                    // L

    float PressurePeak;                             // cmH2O
    float PressureMean;                             // cmH2O
    float PressurePlateau;                          // cmH2O
    float PressurePeep;                             // cmH2O

    float EffectiveInspirationTime;                 // s
    float IERatio;                                  // unitless; how long expiration is compared to inspiration

    uint8_t InstantBreathPhase;                     // see BreathPhase

    float RawUIMessagesPerSecond;                   // count/s
    float ValidUIMessagesPerSecond;                 // count/s
    float MachineStateMessagesPerSecond;            // count/s

    float Debug1;
    float Debug2;
    float Debug3;
    float Debug4;

    int8_t LastReceiveValid = false;
    uint32_t ErrorMask;
};

template <class T>
int32_t GetHash(const T& t)
{
    // FNV-1a
    
    int32_t hash = 0x811c9dc5;
    const int8_t* p = reinterpret_cast<const int8_t*>(&t);
    const int8_t* pEnd = reinterpret_cast<const int8_t*>(&t) + sizeof(t);
    for (; p < pEnd; ++p)
    {
        hash ^= *p;
        // PrintStringHex32("Hash after XOR ", hash); Ln();
        hash *= 0x01000193;
        // PrintStringHex32("Hash after mult", hash); Ln();
    }

    return hash;
}

template <class T>
int GetSerializedSize()
{
    return sizeof(T) + 4;
}

template <class T>
void SendBinary(const T& t)
{
    const uint8_t* p = reinterpret_cast<const uint8_t*>(&t);
    const uint8_t* pEnd = reinterpret_cast<const uint8_t*>(&t) + sizeof(T);
    for (; p < pEnd; ++p)
    {
        Serial.write(*p);
    }
}

template <class T>
void ReadBinary(T& t)
{
    uint8_t* p = reinterpret_cast<uint8_t*>(&t);
    uint8_t* pEnd = reinterpret_cast<uint8_t*>(&t) + sizeof(T);
    for (; p < pEnd; ++p)
    {
        *p = Serial.read();
    }
}

template <class T>
void SendState(const T& state)
{
    int32_t hash = GetHash(state);
    SendBinary(state);
    SendBinary(hash);
}

template <class T>
bool ReceiveState(T& state)
{
    ReadBinary(state);
    int32_t serializedHash;
    ReadBinary(serializedHash);
    int32_t computedHash = GetHash(state);

    return computedHash == serializedHash;
}

bool gLastReceiveValid = false;

void ReceiveUIState(struct UIState& currentUIState)
{
    if (Serial.available() >= GetSerializedSize<UIState>())
    {
        UIState us;
        gLastReceiveValid = ReceiveState(us);

        gReceiveRawUIStateRate.AddEventCount(1);

        if (gLastReceiveValid)
        {
            gReceiveValidUIStateRate.AddEventCount(1);
            us.Validate();
            currentUIState = us;
        }
        else
        {
            // Flush the incoming pipeline in an attempt to resynchronize
            while (Serial.available())
            {
                Serial.read();
            }
        }
    }
}

void SendMachineState(struct MachineState& ms)
{
    ms.RawUIMessagesPerSecond = gReceiveRawUIStateRate.GetRate();
    ms.ValidUIMessagesPerSecond = gReceiveValidUIStateRate.GetRate();
    ms.MachineStateMessagesPerSecond = gSendMachineStateRate.GetRate();

    ms.LastReceiveValid = gLastReceiveValid;
    ms.ErrorMask = gErrorMask;

    SendState(ms);
    
    gSendMachineStateRate.AddEventCount(1);
}

/////////////////////////////
// Signal processing
/////////////////////////////

float LowPassFilter(float current, float target, float ratePerSecond, float deltaSeconds)
{
    float t = powf(ratePerSecond, deltaSeconds);
    return target + (current - target) * t;
}

float HighPassFilter(float current, float target, float lastTarget, float ratePerSecond, float deltaSeconds)
{
    float t = powf(ratePerSecond, deltaSeconds);
    return (current + (target - lastTarget)) * t;
}

float HighPassFilterAbsDelta(float current, float target, float lastTarget, float ratePerSecond, float deltaSeconds)
{
    float t = powf(ratePerSecond, deltaSeconds);
    return (current + abs(target - lastTarget)) * t;
}

float LinearApproach(float current, float target, float ratePerSecond, float deltaSeconds)
{
    float signedDelta = target - current;
    float delta = abs(signedDelta);

    float maxDelta = ratePerSecond * deltaSeconds;
    delta = min(delta, maxDelta);

    delta = copysignf(delta, signedDelta);

    return current + delta;
}

/////////////////////////////
// Breath timing logic
/////////////////////////////

namespace BreathPhase
{
    enum Type
    {
        Inhalation,
        Exhalation,
        Rest
    };
}

class TriggerLogic
{
public:
    TriggerLogic(UIState& uiState)
        : _uiState(uiState)
    {
    }

    void Update()
    {
        ValidateUIState();

        _justTriggered = false;
        
        long nowMs = millis();

        switch (_uiState.TriggerMode)
        {
            case TriggerMode::Off:
                // Nothing to do
                break;

            case TriggerMode::Timed:
                {
                    float desiredMs = GetTimePerTriggeredBreathMs();
                    if (nowMs - _lastTriggerMs > desiredMs)
                    {
                        TriggerWhenPossible();
                    }
                }
                break;

            case TriggerMode::PatientEffort:
                RaiseError(Error::UnimplementedFeature);
                break;

            default:
                RaiseError(Error::InvalidUIInput);
                break;
        }

        if (_pendingTrigger && (nowMs - _lastTriggerMs >= kMinimumReTriggerMs))
        {
            _pendingTrigger = false;

            _justTriggered = true;
            _lastTriggerMs = nowMs;
        }
    }

    void TriggerWhenPossible()
    {
        _pendingTrigger = true;
    }

    bool JustTriggered() const
    {
        return _justTriggered;
    }

    long GetInspiratoryTimeMs() const
    {
        return static_cast<long>(_uiState.InspirationTime * 1000);
    }

    long GetExpiratoryTimeMs() const
    {
        return GetInspiratoryTimeMs() * kMinimumIERatio;
    }

    float GetTimePerTriggeredBreathMs() const
    {
        return 60000.0f / _uiState.TimerTriggerBreathsPerMin;
    }

    long GetExpiratoryAndRestTimeMs() const
    {
        return GetTimePerTriggeredBreathMs() - GetInspiratoryTimeMs();
    }

    // After this amount of time, the patient is considered "at rest" and a breath could be manually retriggered
    long GetCompleteBreathTimeMs() const
    {
        return GetInspiratoryTimeMs() + GetExpiratoryTimeMs();
    }

    float GetIERatio() const
    {
        return GetExpiratoryAndRestTimeMs() / GetInspiratoryTimeMs();
    }

    BreathPhase::Type GetBreathPhase() const
    {
        long timeSinceTrigger = millis() - _lastTriggerMs;

        if (timeSinceTrigger > GetCompleteBreathTimeMs())
        {
            return BreathPhase::Rest;
        }
        else if (timeSinceTrigger > GetInspiratoryTimeMs())
        {
            return BreathPhase::Exhalation;
        }
        else
        {
            return BreathPhase::Inhalation;
        }
        
    }

private:
    const float kMinimumIERatio = 1.0f;
    const long kMinimumReTriggerMs = 2000;
    
    void ValidateUIState()
    {
        float minTimeSeconds = GetTimePerTriggeredBreathMs() / (1.0f + kMinimumIERatio) / 1000.0f;
        _uiState.InspirationTime = min(_uiState.InspirationTime, minTimeSeconds);
    }

    UIState& _uiState;

    bool _pendingTrigger = false;

    long _lastTriggerMs = 0;
    bool _justTriggered = false;
};

/////////////////////////////
// Metric trackers
/////////////////////////////

template <class BreathPhaseTracker, template <class U> class FeatureExtractor>
class PressureTracker
{
public:
    PressureTracker(const TriggerLogic& triggerLogic, const PressureSensor& inhalationPressureSensor)
        : _triggerLogic(triggerLogic)
        , _inhalationPressureSensor(inhalationPressureSensor)
    {
    }

    void Update(float deltaSeconds)
    {
        FeatureExtractor<BreathPhaseTracker>& fe = static_cast<FeatureExtractor<BreathPhaseTracker>&>(*this);

        BreathPhase::Type phase = _triggerLogic.GetBreathPhase();

        if (phase != _lastBreathPhase)
        {
            if (BreathPhaseTracker::IsTrackedPhase(phase) && !BreathPhaseTracker::IsTrackedPhase(_lastBreathPhase))
            {
                fe.BeginTrackedPhase(_inhalationPressureSensor.GetPressureCmH2O());
            }
            else if (!BreathPhaseTracker::IsTrackedPhase(phase) && BreathPhaseTracker::IsTrackedPhase(_lastBreathPhase))
            {
                fe.EndTrackedPhase();
            }

            _lastBreathPhase = phase;
        }

        if (BreathPhaseTracker::IsTrackedPhase(phase))
        {
            fe.UpdateTrackedPhase(_inhalationPressureSensor.GetPressureCmH2O(), deltaSeconds);
        }
    }
private:
    const TriggerLogic& _triggerLogic;
    const PressureSensor& _inhalationPressureSensor;

    BreathPhase::Type _lastBreathPhase = BreathPhase::Rest;
};

struct InhalationPhaseTracker
{
    static bool IsTrackedPhase(BreathPhase::Type phase)
    {
        return phase == BreathPhase::Inhalation;
    }
};

struct ExhalationAndRestPhaseTracker
{
    static bool IsTrackedPhase(BreathPhase::Type phase)
    {
        return phase != BreathPhase::Inhalation;
    }
};

template <class BreathPhaseTracker>
class PeakPressureTracker : public PressureTracker<BreathPhaseTracker, PeakPressureTracker>
{
public:
    PeakPressureTracker(const TriggerLogic& triggerLogic, const PressureSensor& inhalationPressureSensor)
        : PressureTracker<BreathPhaseTracker, PeakPressureTracker>(triggerLogic, inhalationPressureSensor)
    {
    }

    void BeginTrackedPhase(float)
    {
        _peakPressure = 0.0f;
    }

    void EndTrackedPhase()
    {
        _lastPeakPressure = _peakPressure;
    }

    void UpdateTrackedPhase(float pressure, float)
    {
        _peakPressure = max(_peakPressure, pressure);
    }

    float GetPeakPressureCmH2O()
    {
        return _lastPeakPressure;
    }
private:
    float _lastPeakPressure = 0.0f;
    float _peakPressure = 0.0f;
};

template <class BreathPhaseTracker>
class MeanPressureTracker : public PressureTracker<BreathPhaseTracker, PeakPressureTracker>
{
public:
    MeanPressureTracker(const TriggerLogic &triggerLogic, const PressureSensor &inhalationPressureSensor)
        : PressureTracker<BreathPhaseTracker, PeakPressureTracker>(triggerLogic, inhalationPressureSensor)
    {
    }

    void BeginTrackedPhase(float)
    {
        _pressureSum = 0.0f;
        _phaseTime = 0.0f;
    }

    void EndTrackedPhase()
    {
        _lastMeanPressure = _pressureSum / max(_phaseTime, 0.0001f);
    }

    void UpdateTrackedPhase(float pressure, float deltaSeconds)
    {
        _pressureSum += pressure * deltaSeconds;
        _phaseTime += deltaSeconds;
    }

    float GetMeanPressureCmH2O() const
    {
        return _lastMeanPressure;
    }

private:
    float _lastMeanPressure = 0.0f;

    float _pressureSum = 0.0f;
    float _phaseTime = 0.0f;
};

template <class BreathPhaseTracker>
class PlateauPressureTracker : public PressureTracker<BreathPhaseTracker, PlateauPressureTracker>
{
public:
    PlateauPressureTracker(const TriggerLogic &triggerLogic, const PressureSensor &inhalationPressureSensor)
        : PressureTracker<BreathPhaseTracker, PlateauPressureTracker>(triggerLogic, inhalationPressureSensor)
    {
    }

    void BeginTrackedPhase(float pressure)
    {
        _lastPressure = pressure;
        _pressureHpf = 0.0f;

        _isTracking = false;
        _seenPeak = false;
        _pressureSum = 0.0f;
        _phaseTime = 0.0f;
    }

    void EndTrackedPhase()
    {
        _lastPlateauPressure = _pressureSum / max(_phaseTime, 0.0001f);
        _isTracking = false;
    }

    void UpdateTrackedPhase(float pressure, float deltaSeconds)
    {
        _pressureHpf = HighPassFilterAbsDelta(_pressureHpf, pressure, _lastPressure, 0.001f, deltaSeconds);
        _lastPressure = pressure;

        _seenPeak |= (_pressureHpf > 1.0f);

        if (_seenPeak && (_pressureHpf < 1.0f))
        {
            _isTracking = true;
        }

        if (_isTracking)
        {
            _pressureSum += pressure * deltaSeconds;
            _phaseTime += deltaSeconds;
        }
    }

    bool IsTracking()
    {
        return _isTracking;
    }

    float GetPlateauPressureCmH2O() const
    {
        return _lastPlateauPressure;
    }

private:
    float _lastPlateauPressure = 0.0f;
    float _lastPressure = 0.0f;
    float _pressureHpf = 0.0f;

    bool _isTracking = false;
    bool _seenPeak = false;
    float _pressureSum = 0.0f;
    float _phaseTime = 0.0f;
};

class TotalVolumeTracker
{
public:
    TotalVolumeTracker(const TriggerLogic &triggerLogic)
        : _triggerLogic(triggerLogic)
    {
    }

    void Update(float deltaSeconds, float flowLps)
    {
        if (_triggerLogic.JustTriggered())
        {
            _lastVolumeL = _volumeL;
            _volumeL = 0.0f;
        }
        _volumeL += flowLps * deltaSeconds;
    }

    float GetVolumeL() const
    {
        return _lastVolumeL;
    }

    float GetInstantVolumeL() const
    {
        return _volumeL;
    }

private:
    const TriggerLogic& _triggerLogic;
    float _lastVolumeL = 0.0f;
    float _volumeL = 0.0f;
};


/////////////////////////////
// Virtual lung simulation
/////////////////////////////

#if VIRTUAL_INPUTS
class VirtualLung
{
public:
    VirtualLung(float capacityL, float startingGasL, float pressureAtCapacity)
        : _capacityL(capacityL)
        , _containedGasL(startingGasL)
        , _pressureAtCapacity(pressureAtCapacity)
        , _flowLps(0.0f)
    {
    }

    void Update(float pressure, float deltaSeconds)
    {
        float backPressure = (_containedGasL / _capacityL) * _pressureAtCapacity;
        
        float deltaPressure = pressure - backPressure;
        _flowLps = copysign(powf(abs(deltaPressure), (deltaPressure > 0.0f) ? 0.6f : 0.8f) / kFlowResistance, deltaPressure); // simulate a bit of drag

        _containedGasL += _flowLps * deltaSeconds;
        _containedGasL = max(_containedGasL, 0.0f);
    }

    float GetContainedGas()
    {
        return _containedGasL;
    }

    float GetFlowLps()
    {
        return _flowLps;
    }

    float GetFlowSlpm()
    {
        return _flowLps * 60.0f;
    }

private:
    const float kFlowResistance = 8.0f;

    float _capacityL = 0.0f;
    float _containedGasL = 0.0f;

    float _pressureAtCapacity = 0.0f;

    float _flowLps = 0.0f;
};
#endif

/////////////////////////////
// Initialization and control loop
/////////////////////////////

void ProcessUIStateEvents(struct UIState& uiState, class TriggerLogic& triggerLogic)
{
    if (uiState.BreathManuallyTriggered != 0)
    {
        triggerLogic.TriggerWhenPossible();
        uiState.BreathManuallyTriggered = 0;
    }
}

#if !VIRTUAL_INPUTS
SoftwareWire SWire(PIN_SOFTWARE_I2C_SDA, PIN_SOFTWARE_I2C_SCL);
#else
EmptyPlaceholderType Wire;
EmptyPlaceholderType SWire;
#endif

void setup()
{
    pinMode(13, OUTPUT);

#if !VIRTUAL_INPUTS
    Wire.begin();
    Wire.setClock(100000);
    SWire.begin();
    SWire.setClock(100000);
#endif

    Serial.begin(115200);
    while (!Serial);
}

#define ENABLE_INHALATION_PRESSURE_SENSOR 1
#define ENABLE_EXHALATION_PRESSURE_SENSOR 1
#define ENABLE_INHALATION_FLOW_SENSOR 1
#define ENABLE_EXHALATION_FLOW_SENSOR 1
#define ENABLE_HUMIDITY_TEMPERATURE_SENSOR 0

#define ENABLE_ALARM 1
#define ENABLE_O2_VALVE_SERVO 1
#define ENABLE_AIR_VALVE_SERVO 1

void ConfigureDefaultUIState(UIState& uiState)
{
    uiState.FiO2 = 0.5f;
    uiState.ControlMode = 1;
    uiState.PressureControlInspiratoryPressure = 15.0f;
    // uiState.VolumeControlMaxPressure = 25.0f;
    // uiState.VolumeControlTidalVolume = 0.450f;
    uiState.Peep = 5.0f;
    uiState.InspirationTime = 1.0f;
    uiState.InspirationFilterRate = 0.01f;
    uiState.ExpirationFilterRate = 0.02f;
    uiState.TriggerMode = 1;
    uiState.TimerTriggerBreathsPerMin = 20;
    // uiState.PatientEffortTriggerMinBreathsPerMin = 8;
    // uiState.PatientEffortTriggerLitersPerMin = 2.5f;
}

void loop()
{
    // Give the UI time to boot up - @TODO: message resynchronization
    // for (int i = 0; i < 5; ++i)
    // {
    //     Blink(100);
    // }

#if ENABLE_INHALATION_PRESSURE_SENSOR
    // DEFAULT_PRINT->print(F("Initializing inhalation pressure sensor...")); Ln();
    PressureSensor inhalationPressureSensor(PIN_INHALE_PRESSURE_SENSOR);
#endif

#if ENABLE_EXHALATION_PRESSURE_SENSOR
    // DEFAULT_PRINT->print(F("Initializing exhalation pressure sensor...")); Ln();
    PressureSensor exhalationPressureSensor(PIN_EXHALE_PRESSURE_SENSOR);
#endif

#if ENABLE_INHALATION_FLOW_SENSOR
    // DEFAULT_PRINT->print(F("Initializing inhalation flow sensor (hardware I2C)...")); Ln();
    FlowSensor<typeof(Wire)> inhalationFlowSensor(Wire);
    // DEFAULT_PRINT->print(F("Inhalation serial: 0x"));
    // PrintHex32(inhalationFlowSensor.GetSerial());
    // Ln();
#endif

#if ENABLE_EXHALATION_FLOW_SENSOR
    // DEFAULT_PRINT->print(F("Initializing exhalation flow sensor (software I2C)...")); Ln();
    FlowSensor<typeof(SWire)> exhalationFlowSensor(SWire);
    // DEFAULT_PRINT->print(F("Exhalation serial: 0x"));
    // PrintHex32(exhalationFlowSensor.GetSerial());
    // Ln();
#endif

#if ENABLE_HUMIDITY_TEMPERATURE_SENSOR
    DEFAULT_PRINT->print(F("Initializing humidity and temperature sensor...")); Ln();
    HumidityTemperatureSensor<typeof(Wire)> humidityTemperatureSensor(Wire);
    Ln();
#endif

#if ENABLE_ALARM
    NoiseMaker alarm(PIN_ALARM_SPEAKER);
    alarm.SetEnabled(true);
#endif

#if ENABLE_O2_VALVE_SERVO
    ProportionalValve o2Valve(PIN_O2_VALVE, 14.0f, 124.0f);
#endif
#if ENABLE_AIR_VALVE_SERVO
    ProportionalValve airValve(PIN_AIR_VALVE, 3.0f, 90.0f);
#endif

#if ENABLE_ALARM
    long lastNoiseTimeMs = 0;
#endif

    long lastUpdateMs = 0;

    UIState uiState;
    Zero(uiState);
    ConfigureDefaultUIState(uiState);
    
    MachineState machineState;
    Zero(machineState);

    TriggerLogic triggerLogic(uiState);

    PeakPressureTracker<InhalationPhaseTracker> peakPressureTracker(triggerLogic, inhalationPressureSensor);
    MeanPressureTracker<InhalationPhaseTracker> meanPressureTracker(triggerLogic, inhalationPressureSensor);
    PlateauPressureTracker<InhalationPhaseTracker> plateauPressureTracker(triggerLogic, inhalationPressureSensor);
    PlateauPressureTracker<ExhalationAndRestPhaseTracker> peepPressureTracker(triggerLogic, inhalationPressureSensor);

    TotalVolumeTracker totalInhalationVolumeTracker(triggerLogic);
    TotalVolumeTracker totalExhalationVolumeTracker(triggerLogic);
    TotalVolumeTracker totalVolumeTracker(triggerLogic);

#if VIRTUAL_INPUTS
    VirtualLung lung(0.650f, 0.150f, 25.0f);
#endif

    float o2Opening = 0.0f;
    float airOpening = 0.0f;
    float lastError = 0.0f;
    float lastTargetInhalationPressure = 0.0f;

    for (;;)
    {
        long nowMs = millis();
        float deltaSeconds = (nowMs - lastUpdateMs) / 1000.0f;

        lastUpdateMs = nowMs;

        gReceiveRawUIStateRate.Update();
        gReceiveValidUIStateRate.Update();
        gSendMachineStateRate.Update();

#if VIRTUAL_INPUTS
        o2Valve.Update(deltaSeconds);
        airValve.Update(deltaSeconds);
        inhalationPressureSensor.SetVirtualServoOpening(o2Valve.GetPosition01(), airValve.GetPosition01(), deltaSeconds);
        exhalationPressureSensor.SetVirtualServoOpening(o2Valve.GetPosition01(),  airValve.GetPosition01(), deltaSeconds);
        lung.Update(inhalationPressureSensor.GetPressureCmH2O(), deltaSeconds);
        inhalationFlowSensor.SetVirtualLungFlow(lung.GetFlowSlpm(), true);
        exhalationFlowSensor.SetVirtualLungFlow(lung.GetFlowSlpm(), false);
#endif

        ReceiveUIState(uiState);

        ProcessUIStateEvents(uiState, triggerLogic);

        triggerLogic.Update();
        peakPressureTracker.Update(deltaSeconds);
        meanPressureTracker.Update(deltaSeconds);
        plateauPressureTracker.Update(deltaSeconds);
        peepPressureTracker.Update(deltaSeconds);

        totalInhalationVolumeTracker.Update(deltaSeconds, inhalationFlowSensor.GetFlowLps());
        totalExhalationVolumeTracker.Update(deltaSeconds, exhalationFlowSensor.GetFlowLps());

        float totalFlowSlpm = inhalationFlowSensor.GetFlowSlpm() - exhalationFlowSensor.GetFlowSlpm();
        float totalFlowLps = inhalationFlowSensor.GetFlowLps() - exhalationFlowSensor.GetFlowLps();
        totalVolumeTracker.Update(deltaSeconds, totalFlowLps);

        float targetInhalationPressure = 0.0f;
        switch (uiState.ControlMode)
        {
            case ControlMode::Off:
               break;
            case ControlMode::PressureControl:
                targetInhalationPressure = (triggerLogic.GetBreathPhase() == BreathPhase::Inhalation) ? uiState.PressureControlInspiratoryPressure + uiState.Peep : uiState.Peep;
                break;
            case ControlMode::VolumeControl:
                RaiseError(Error::UnimplementedFeature);
                break;
        }

        float deltaTargetInhalationPressure = targetInhalationPressure - lastTargetInhalationPressure;
        lastTargetInhalationPressure = targetInhalationPressure;

        float inhalationPressure = inhalationPressureSensor.GetPressureCmH2O();

        float error = targetInhalationPressure - inhalationPressure;
        
        float errorRate = (error - lastError - deltaTargetInhalationPressure) / deltaSeconds;
        lastError = error;
        
        const float kP = 0.5f;
        const float kD = 0.0f;
        // const float kD = 0.0f;

        float correctionP = error * kP * deltaSeconds;
        float correctionD = errorRate * kD * deltaSeconds;
        
        float correction = correctionP + correctionD;

        // Work out relative valve openings based on FiO2
        float o2Proportion = uiState.FiO2;
        float airProportion = 1.0f - uiState.FiO2;

        o2Opening += o2Proportion * correction;
        airOpening += airProportion * correction;

        o2Opening = Clamp01(o2Opening);
        airOpening = Clamp01(airOpening);

        //@TODO: map to physical valve response
#if ENABLE_O2_VALVE_SERVO
        o2Valve.SetPosition01(o2Opening);
#endif

#if ENABLE_AIR_VALVE_SERVO
        airValve.SetPosition01(airOpening);
#endif

        // if (nowMs - lastSendMs > kMachineStateSendIntervalMs)
        {
            machineState.InstantInhalationPressure = inhalationPressureSensor.GetPressureCmH2O();
            machineState.InstantInhalationFlow = inhalationFlowSensor.GetFlowSlpm();
            machineState.InstantExhalationPressure = exhalationPressureSensor.GetPressureCmH2O();
            machineState.InstantExhalationFlow = exhalationFlowSensor.GetFlowSlpm();
            machineState.InstantO2ValveOpening = o2Opening;
            machineState.InstantAirValveOpening = airOpening;
            machineState.InstantTotalVolume = totalVolumeTracker.GetInstantVolumeL();
            machineState.InstantTotalFlowLitersPerMin = totalFlowSlpm;
            machineState.MinuteExhalationLitersPerMin = totalExhalationVolumeTracker.GetVolumeL() * uiState.TimerTriggerBreathsPerMin;
            machineState.RespiratoryFrequencyBreathsPerMin = uiState.TimerTriggerBreathsPerMin;
            machineState.InhalationTidalVolume = totalInhalationVolumeTracker.GetVolumeL();
            machineState.ExhalationTidalVolume = totalExhalationVolumeTracker.GetVolumeL();
            machineState.PressurePeak = peakPressureTracker.GetPeakPressureCmH2O();
            machineState.PressureMean = meanPressureTracker.GetMeanPressureCmH2O();
            machineState.PressurePlateau = plateauPressureTracker.GetPlateauPressureCmH2O();
            machineState.PressurePeep = peepPressureTracker.GetPlateauPressureCmH2O();
            machineState.EffectiveInspirationTime = uiState.InspirationTime;
            machineState.IERatio = triggerLogic.GetIERatio();
            machineState.InstantBreathPhase = triggerLogic.GetBreathPhase();

            SendMachineState(machineState);

            delay(5);
        }
    }

    for (;;)
    {

#if ENABLE_INHALATION_PRESSURE_SENSOR
        float inhalationPressure = inhalationPressureSensor.GetPressurePsi();
        PrintStringFloat(F("Inh P"), inhalationPressure);
        DEFAULT_PRINT->print(F(" PSI  "));
#endif
#if ENABLE_EXHALATION_PRESSURE_SENSOR
        float exhalationPressure = exhalationPressureSensor.GetPressurePsi();
        PrintStringFloat(F("Exh P"), exhalationPressure); 
        DEFAULT_PRINT->print(F(" PSI  "));
#endif

#if ENABLE_INHALATION_FLOW_SENSOR
        float inhalationFlow = inhalationFlowSensor.GetFlowSlpm();
        PrintStringFloat(F("Inh F"), inhalationFlow);
        DEFAULT_PRINT->print(F(" SLPM  "));
#endif

#if ENABLE_EXHALATION_FLOW_SENSOR
        float exhalationFlow = exhalationFlowSensor.GetFlowSlpm();
        PrintStringFloat(F("Exh F"), exhalationFlow);
        DEFAULT_PRINT->print(F(" SLPM "));
#endif

#if ENABLE_HUMIDITY_TEMPERATURE_SENSOR
        float humidity = humidityTemperatureSensor.GetHumidity01();
        float temperature = humidityTemperatureSensor.GetTemperature();
        PrintStringFloat(F("H"), humidity * 100);
        DEFAULT_PRINT->print(F(" %RH  "));
        PrintStringFloat(F("T"), temperature);
        DEFAULT_PRINT->print(F(" C  "));
#endif

        Ln();

#if ENABLE_ALARM
        alarm.Update();
        long nowMs = millis();
        if (nowMs - lastNoiseTimeMs > 1000)
        {
            // Serial.write("bleep!\n");
            alarm.Laser();
            lastNoiseTimeMs = nowMs;
        }
#endif

#if ENABLE_O2_VALVE_SERVO
        float o2Position = Clamp01(inhalationFlow / 16.0f);
        o2Valve.SetPosition01(o2Position);
#endif

#if ENABLE_AIR_VALVE_SERVO
        float airPosition = Clamp01(exhalationFlow / 16.0f);
        airValve.SetPosition01(airPosition);
#endif
    }
}