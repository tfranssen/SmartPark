function Encode(object, fport) {
    var bytes = [];
    //settings
    if (fport === 3){
        bytes[0] = (object.system_status_interval) & 0xFF;
        bytes[1] = (object.system_status_interval)>>8 & 0xFF;

        bytes[2] |= object.system_functions.accelerometer_enabled  ? 1<<3 : 0;
        bytes[2] |= object.system_functions.light_enabled  ? 1<<4 : 0;
        bytes[2] |= object.system_functions.temperature_enabled  ? 1<<5 : 0;
        bytes[2] |= object.system_functions.humidity_enabled  ? 1<<6 : 0;
        bytes[2] |= object.system_functions.charging_enabled  ? 1<<7 : 0;

        bytes[3] |= (object.lorawan_datarate_adr.datarate) & 0x0F;
        bytes[3] |= object.lorawan_datarate_adr.confirmed_uplink ? 1<<6 : 0;
        bytes[3] |= object.lorawan_datarate_adr.adr ? 1<<7 : 0;

        bytes[4] = (object.gps_periodic_interval) & 0xFF;
        bytes[5] = (object.gps_periodic_interval)>>8 & 0xFF;

        bytes[6] = (object.gps_triggered_interval) & 0xFF;
        bytes[7] = (object.gps_triggered_interval)>>8 & 0xFF;

        bytes[8] = (object.gps_triggered_threshold) & 0xFF;

        bytes[9] = (object.gps_triggered_duration) & 0xFF;

        bytes[10] = (object.gps_cold_fix_timeout) & 0xFF;
        bytes[11] = (object.gps_cold_fix_timeout)>>8 & 0xFF;

        bytes[12] = (object.gps_hot_fix_timeout) & 0xFF;
        bytes[13] = (object.gps_hot_fix_timeout)>>8 & 0xFF;

        bytes[14] = (object.gps_min_fix_time) & 0xFF;

        bytes[15] = (object.gps_min_ehpe) & 0xFF;

        bytes[16] = (object.gps_hot_fix_retry) & 0xFF;

        bytes[17] = (object.gps_cold_fix_retry) & 0xFF;
        
        bytes[18] = (object.gps_fail_retry) & 0xFF;

        bytes[19] = object.gps_settings.d3_fix ? 1<<0 : 0;
        bytes[19] |= object.gps_settings.fail_backoff ? 1<<1 : 0;
        bytes[19] |= object.gps_settings.hot_fix ? 1<<2 : 0;
        bytes[19] |= object.gps_settings.fully_resolved ? 1<<3 : 0;
        bytes[20] = (object.system_voltage_interval) & 0xFF;
        bytes[21] = ((object.gps_charge_min-2500)/10) & 0xFF;
        bytes[22] = ((object.system_charge_min-2500)/10) & 0xFF;
        bytes[23] = ((object.system_charge_max-2500)/10) & 0xFF;
        bytes[24] = (object.system_input_charge_min) & 0xFF;
        bytes[25] = (object.system_input_charge_min)>>8 & 0xFF;
    }
    else if (fport === 30){
        bytes[0] = (object.freq_start) & 0xFF;
        bytes[1] = (object.freq_start)>>8 & 0xFF;
        bytes[2] = (object.freq_start)>>16 & 0xFF;
        bytes[3] = (object.freq_start)>>24 & 0xFF;

        bytes[4] = (object.freq_stop) & 0xFF;
        bytes[5] = (object.freq_stop)>>8 & 0xFF;
        bytes[6] = (object.freq_stop)>>16 & 0xFF;
        bytes[7] = (object.freq_stop)>>24 & 0xFF;

        bytes[8] = (object.samples) & 0xFF;
        bytes[9] = (object.samples)>>8 & 0xFF;
        bytes[10] = (object.samples)>>16 & 0xFF;
        bytes[11] = (object.samples)>>24 & 0xFF;

        bytes[12] = (object.power) & 0xFF;
        bytes[13] = (object.power)>>8 & 0xFF;

        bytes[14] = (object.time) & 0xFF;
        bytes[15] = (object.time)>>8 & 0xFF;

        bytes[16] = (object.type) & 0xFF;
        bytes[17] = (object.type)>>8 & 0xFF;
    }
    //command
    else if (fport === 99){
        if(object.command.reset){
            bytes[0]=0xab;
        }
        else if(object.command.lora_rejoin){
            bytes[0]=0xde;
        }
        else if(object.command.send_settings){
            bytes[0]=0xaa;
        }
    }
    return bytes;
  } 
var encoded =  Encode({"system_status_interval": 5, "system_functions": {"accelerometer_enabled": false, "light_enabled": false, "temperature_enabled": false, "humidity_enabled": false, "charging_enabled": true}, "lorawan_datarate_adr": {"datarate": 5, "confirmed_uplink": false, "adr": false}, "gps_periodic_interval": 1, "gps_triggered_interval": 0, "gps_triggered_threshold": 10, "gps_triggered_duration": 10, "gps_cold_fix_timeout": 200, "gps_hot_fix_timeout": 60, "gps_min_fix_time": 1, "gps_min_ehpe": 50, "gps_hot_fix_retry": 5, "gps_cold_fix_retry": 20, "gps_fail_retry": 0, "gps_settings": {"d3_fix": true, "fail_backoff": false, "hot_fix": true, "fully_resolved": false}, "system_voltage_interval": 1, "gps_charge_min": 2500, "system_charge_min": 3450, "system_charge_max": 4000, "system_input_charge_min": 10000, "pulse_threshold": 3, "pulse_on_timeout": 60, "pulse_min_interval": 1, "gps_accel_z_threshold": 0},3)
console.log(encoded)
var encoded64 = "";
for(let i = 0; i < encoded.length; i++){
    let row = encoded[i]; 
    row = row.toString()
    let opt = {};
    opt = Buffer.from(row).toString('base64');
    encoded64 = encoded64 + opt;  
}
var encodedhex = "";
for(let i = 0; i < encoded.length; i++){
    let row = encoded[i];
    let opt = {};
    opt = row.toString(16);
    encodedhex = encodedhex + opt + ',';  
}
console.log("Encoder output:");
console.log(encoded.toString());
console.log("Encoder output converted to base64 individual:");
console.log(encoded64);
console.log("Encoder output converted to hex individual:");
console.log(encodedhex);
console.log("Encoder output converted to base64 as string:")
console.log(Buffer.from(encoded.toString()).toString('base64'));