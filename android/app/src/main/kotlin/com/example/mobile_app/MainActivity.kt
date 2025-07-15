package com.example.mobile_app

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import net.posprinter.POSConnect
import net.posprinter.POSPrinter
import net.posprinter.POSConst
import net.posprinter.IDeviceConnection
import net.posprinter.IConnectListener

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.mobile_app/printer"
    private val BLUETOOTH_PERMISSION_REQUEST_CODE = 1001
    
    private var deviceConnection: IDeviceConnection? = null
    private var printer: POSPrinter? = null
    
    // Bluetooth related
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var bluetoothManager: BluetoothManager? = null
    private val discoveredDevices = mutableListOf<BluetoothDevice>()
    private var bluetoothDiscoveryResult: MethodChannel.Result? = null

    // Connect listener for printer connections
    private val connectListener = IConnectListener { code, connInfo, msg ->
        when (code) {
            POSConnect.CONNECT_SUCCESS -> {
                // Connection successful
                printer = POSPrinter(deviceConnection)
            }
            POSConnect.CONNECT_FAIL -> {
                // Connection failed
                deviceConnection = null
                printer = null
            }
            POSConnect.CONNECT_INTERRUPT -> {
                // Connection interrupted
                deviceConnection = null
                printer = null
            }
        }
    }

    // Bluetooth discovery receiver
    private val bluetoothReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                BluetoothDevice.ACTION_FOUND -> {
                    val device: BluetoothDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
                    } else {
                        @Suppress("DEPRECATION")
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    }
                    
                    device?.let {
                        if (!discoveredDevices.contains(it)) {
                            discoveredDevices.add(it)
                        }
                    }
                }
                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                    bluetoothDiscoveryResult?.let { result ->
                        val devices = discoveredDevices.map { device ->
                            mapOf(
                                "name" to (device.name ?: "Unknown Device"),
                                "address" to device.address,
                                "bondState" to device.bondState
                            )
                        }
                        result.success(devices)
                        bluetoothDiscoveryResult = null
                    }
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize POSConnect
        POSConnect.init(this)
        
        // Initialize Bluetooth
        bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager?.adapter
        
        // Register Bluetooth receiver
        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_FOUND)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        }
        registerReceiver(bluetoothReceiver, filter)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(bluetoothReceiver)
        deviceConnection?.close()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "connectPrinter" -> {
                    val address = call.argument<String>("address")
                    val port = call.argument<Int>("port") ?: 9100
                    connectPrinter(address, port, result)
                }
                "connectBluetoothPrinter" -> {
                    val address = call.argument<String>("address")
                    connectBluetoothPrinter(address, result)
                }
                "disconnectPrinter" -> {
                    disconnectPrinter(result)
                }
                "printPdf" -> {
                    val pdfBytes = call.argument<ByteArray>("pdfBytes")
                    printPdf(pdfBytes, result)
                }
                "getPrinterStatus" -> {
                    getPrinterStatus(result)
                }
                "discoverBluetoothDevices" -> {
                    discoverBluetoothDevices(result)
                }
                "getPairedBluetoothDevices" -> {
                    getPairedBluetoothDevices(result)
                }
                "checkBluetoothPermissions" -> {
                    checkBluetoothPermissions(result)
                }
                "requestBluetoothPermissions" -> {
                    requestBluetoothPermissions(result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun connectPrinter(address: String?, port: Int, result: MethodChannel.Result) {
        if (address == null) {
            result.error("INVALID_ADDRESS", "Printer address is required", null)
            return
        }

        try {
            deviceConnection?.close()
            deviceConnection = POSConnect.createDevice(POSConnect.DEVICE_TYPE_ETHERNET)
            deviceConnection?.connect(address, connectListener)
            result.success(true)
        } catch (e: Exception) {
            result.error("CONNECTION_ERROR", "Error connecting to printer: ${e.message}", null)
        }
    }

    private fun disconnectPrinter(result: MethodChannel.Result) {
        try {
            deviceConnection?.close()
            deviceConnection = null
            printer = null
            result.success(true)
        } catch (e: Exception) {
            result.error("DISCONNECT_ERROR", "Error disconnecting printer: ${e.message}", null)
        }
    }

    private fun printPdf(pdfBytes: ByteArray?, result: MethodChannel.Result) {
        if (pdfBytes == null) {
            result.error("INVALID_PDF", "PDF bytes are required", null)
            return
        }

        if (printer == null) {
            result.error("NO_PRINTER", "Printer not connected", null)
            return
        }

        try {
            // Convert PDF bytes to bitmap and print
            // This is a simplified implementation - you might need to use a PDF-to-image library
            // For now, we'll just print a placeholder text
            printer?.let { p ->
                p.initializePrinter()
                    .setAlignment(POSConst.ALIGNMENT_CENTER)
                    .printString("BARCODE PRINTOUT")
                    .printString("------------------------")
                    .printString("Sample Barcode")
                    .printString("Printed from Mobile App")
                    .printString("------------------------")
                    .feedLine(3)
                    .cutHalfAndFeed(1)
                
                result.success(true)
            }
        } catch (e: Exception) {
            result.error("PRINT_ERROR", "Error printing PDF: ${e.message}", null)
        }
    }

    private fun getPrinterStatus(result: MethodChannel.Result) {
        if (printer == null) {
            result.error("NO_PRINTER", "Printer not connected", null)
            return
        }

        try {
            printer?.printerStatus { status ->
                val statusString = when (status) {
                    POSConst.STS_NORMAL -> "NORMAL"
                    POSConst.STS_COVEROPEN -> "COVER_OPEN"
                    POSConst.STS_PAPEREMPTY -> "PAPER_EMPTY"
                    POSConst.STS_PRESS_FEED -> "PRESS_FEED"
                    POSConst.STS_PRINTER_ERR -> "PRINTER_ERROR"
                    else -> "UNKNOWN"
                }
                result.success(statusString)
            }
        } catch (e: Exception) {
            result.error("STATUS_ERROR", "Error getting printer status: ${e.message}", null)
        }
    }

    // Bluetooth Methods
    
    private fun checkBluetoothPermissions(result: MethodChannel.Result) {
        val permissions = mutableListOf<String>()
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permissions.addAll(listOf(
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.BLUETOOTH_SCAN
            ))
        } else {
            permissions.addAll(listOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_ADMIN,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ))
        }
        
        val hasPermissions = permissions.all { permission ->
            ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
        }
        
        result.success(hasPermissions)
    }

    private fun requestBluetoothPermissions(result: MethodChannel.Result) {
        val permissions = mutableListOf<String>()
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permissions.addAll(listOf(
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.BLUETOOTH_SCAN
            ))
        } else {
            permissions.addAll(listOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_ADMIN,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ))
        }
        
        ActivityCompat.requestPermissions(this, permissions.toTypedArray(), BLUETOOTH_PERMISSION_REQUEST_CODE)
        result.success(true)
    }

    private fun getPairedBluetoothDevices(result: MethodChannel.Result) {
        if (bluetoothAdapter == null) {
            result.error("BLUETOOTH_NOT_SUPPORTED", "Bluetooth is not supported on this device", null)
            return
        }

        if (!bluetoothAdapter!!.isEnabled) {
            result.error("BLUETOOTH_DISABLED", "Bluetooth is not enabled", null)
            return
        }

        try {
            val pairedDevices = bluetoothAdapter!!.bondedDevices
            val devices = pairedDevices.map { device ->
                mapOf(
                    "name" to (device.name ?: "Unknown Device"),
                    "address" to device.address,
                    "bondState" to device.bondState
                )
            }
            result.success(devices)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", "Bluetooth permission denied", null)
        } catch (e: Exception) {
            result.error("ERROR", "Error getting paired devices: ${e.message}", null)
        }
    }

    private fun discoverBluetoothDevices(result: MethodChannel.Result) {
        if (bluetoothAdapter == null) {
            result.error("BLUETOOTH_NOT_SUPPORTED", "Bluetooth is not supported on this device", null)
            return
        }

        if (!bluetoothAdapter!!.isEnabled) {
            result.error("BLUETOOTH_DISABLED", "Bluetooth is not enabled", null)
            return
        }

        try {
            discoveredDevices.clear()
            bluetoothDiscoveryResult = result
            
            if (bluetoothAdapter!!.isDiscovering) {
                bluetoothAdapter!!.cancelDiscovery()
            }
            
            bluetoothAdapter!!.startDiscovery()
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", "Bluetooth permission denied", null)
        } catch (e: Exception) {
            result.error("ERROR", "Error starting device discovery: ${e.message}", null)
        }
    }

    private fun connectBluetoothPrinter(address: String?, result: MethodChannel.Result) {
        if (address == null) {
            result.error("INVALID_ADDRESS", "Bluetooth address is required", null)
            return
        }

        if (bluetoothAdapter == null) {
            result.error("BLUETOOTH_NOT_SUPPORTED", "Bluetooth is not supported on this device", null)
            return
        }

        if (!bluetoothAdapter!!.isEnabled) {
            result.error("BLUETOOTH_DISABLED", "Bluetooth is not enabled", null)
            return
        }

        try {
            deviceConnection?.close()
            deviceConnection = POSConnect.createDevice(POSConnect.DEVICE_TYPE_BLUETOOTH)
            deviceConnection?.connect(address, connectListener)
            result.success(true)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", "Bluetooth permission denied", null)
        } catch (e: Exception) {
            result.error("CONNECTION_ERROR", "Error connecting to Bluetooth printer: ${e.message}", null)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == BLUETOOTH_PERMISSION_REQUEST_CODE) {
            val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            // Handle permission result if needed
        }
    }
}
