import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'app_logger.dart';

enum PrinterStatus {
  normal,
  coverOpen,
  paperEmpty,
  pressFeed,
  printerError,
  unknown,
}

enum ConnectionType {
  tcp,
  bluetooth,
}

class BluetoothDevice {
  final String name;
  final String address;
  final int bondState;

  BluetoothDevice({
    required this.name,
    required this.address,
    required this.bondState,
  });

  factory BluetoothDevice.fromMap(Map<String, dynamic> map) {
    return BluetoothDevice(
      name: map['name'] as String,
      address: map['address'] as String,
      bondState: map['bondState'] as int,
    );
  }

  bool get isPaired => bondState == 12; // BluetoothDevice.BOND_BONDED
}

@singleton
class PrinterService {
  static const MethodChannel _channel =
      MethodChannel('com.example.mobile_app/printer');

  bool _isConnected = false;
  String? _connectedAddress;
  ConnectionType? _connectionType;

  bool get isConnected => _isConnected;
  String? get connectedAddress => _connectedAddress;
  ConnectionType? get connectionType => _connectionType;

  /// Connect to printer via TCP/IP
  Future<bool> connectPrinter(String address, {int port = 9100}) async {
    try {
      AppLogger.info('Connecting to printer at $address:$port');

      final result = await _channel.invokeMethod('connectPrinter', {
        'address': address,
        'port': port,
      });

      if (result == true) {
        _isConnected = true;
        _connectedAddress = address;
        _connectionType = ConnectionType.tcp;
        AppLogger.info('Successfully connected to TCP printer');
        return true;
      } else {
        AppLogger.error('Failed to connect to TCP printer');
        return false;
      }
    } on PlatformException catch (e) {
      AppLogger.error(
          'Platform error connecting to printer: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      AppLogger.error('Error connecting to printer: $e');
      return false;
    }
  }

  /// Disconnect from printer
  Future<bool> disconnectPrinter() async {
    try {
      AppLogger.info('Disconnecting from printer');

      final result = await _channel.invokeMethod('disconnectPrinter');

      if (result == true) {
        _isConnected = false;
        _connectedAddress = null;
        _connectionType = null;
        AppLogger.info('Successfully disconnected from printer');
        return true;
      } else {
        AppLogger.error('Failed to disconnect from printer');
        return false;
      }
    } on PlatformException catch (e) {
      AppLogger.error(
          'Platform error disconnecting from printer: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      AppLogger.error('Error disconnecting from printer: $e');
      return false;
    }
  }

  /// Print PDF bytes
  Future<bool> printPdf(Uint8List pdfBytes) async {
    if (!_isConnected) {
      AppLogger.error('Cannot print: printer not connected');
      return false;
    }

    try {
      AppLogger.info('Printing PDF with ${pdfBytes.length} bytes');

      final result = await _channel.invokeMethod('printPdf', {
        'pdfBytes': pdfBytes,
      });

      if (result == true) {
        AppLogger.info('Successfully printed PDF');
        return true;
      } else {
        AppLogger.error('Failed to print PDF');
        return false;
      }
    } on PlatformException catch (e) {
      AppLogger.error('Platform error printing PDF: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      AppLogger.error('Error printing PDF: $e');
      return false;
    }
  }

  /// Get printer status
  Future<PrinterStatus> getPrinterStatus() async {
    if (!_isConnected) {
      AppLogger.error('Cannot get status: printer not connected');
      return PrinterStatus.unknown;
    }

    try {
      final result = await _channel.invokeMethod('getPrinterStatus');

      switch (result) {
        case 'NORMAL':
          return PrinterStatus.normal;
        case 'COVER_OPEN':
          return PrinterStatus.coverOpen;
        case 'PAPER_EMPTY':
          return PrinterStatus.paperEmpty;
        case 'PRESS_FEED':
          return PrinterStatus.pressFeed;
        case 'PRINTER_ERROR':
          return PrinterStatus.printerError;
        default:
          return PrinterStatus.unknown;
      }
    } on PlatformException catch (e) {
      AppLogger.error(
          'Platform error getting printer status: ${e.code} - ${e.message}');
      return PrinterStatus.unknown;
    } catch (e) {
      AppLogger.error('Error getting printer status: $e');
      return PrinterStatus.unknown;
    }
  }

  /// Check if printer is ready to print
  Future<bool> isPrinterReady() async {
    if (!_isConnected) return false;

    final status = await getPrinterStatus();
    return status == PrinterStatus.normal;
  }

  /// Check if Bluetooth permissions are granted
  Future<bool> checkBluetoothPermissions() async {
    try {
      final result = await _channel.invokeMethod('checkBluetoothPermissions');
      return result == true;
    } on PlatformException catch (e) {
      AppLogger.error(
          'Platform error checking Bluetooth permissions: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      AppLogger.error('Error checking Bluetooth permissions: $e');
      return false;
    }
  }

  /// Request Bluetooth permissions
  Future<bool> requestBluetoothPermissions() async {
    try {
      final result = await _channel.invokeMethod('requestBluetoothPermissions');
      return result == true;
    } on PlatformException catch (e) {
      AppLogger.error(
          'Platform error requesting Bluetooth permissions: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      AppLogger.error('Error requesting Bluetooth permissions: $e');
      return false;
    }
  }

  /// Get paired Bluetooth devices
  Future<List<BluetoothDevice>> getPairedBluetoothDevices() async {
    try {
      final result = await _channel.invokeMethod('getPairedBluetoothDevices');

      if (result is List) {
        return result
            .map((device) =>
                BluetoothDevice.fromMap(Map<String, dynamic>.from(device)))
            .toList();
      }

      return [];
    } on PlatformException catch (e) {
      AppLogger.error(
          'Platform error getting paired Bluetooth devices: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      AppLogger.error('Error getting paired Bluetooth devices: $e');
      return [];
    }
  }

  /// Discover Bluetooth devices
  Future<List<BluetoothDevice>> discoverBluetoothDevices() async {
    try {
      AppLogger.info('Starting Bluetooth device discovery');

      final result = await _channel.invokeMethod('discoverBluetoothDevices');

      if (result is List) {
        final devices = result
            .map((device) =>
                BluetoothDevice.fromMap(Map<String, dynamic>.from(device)))
            .toList();
        AppLogger.info('Found ${devices.length} Bluetooth devices');
        return devices;
      }

      return [];
    } on PlatformException catch (e) {
      AppLogger.error(
          'Platform error discovering Bluetooth devices: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      AppLogger.error('Error discovering Bluetooth devices: $e');
      return [];
    }
  }

  /// Connect to printer via Bluetooth
  Future<bool> connectBluetoothPrinter(String address) async {
    try {
      AppLogger.info('Connecting to Bluetooth printer at $address');

      final result = await _channel.invokeMethod('connectBluetoothPrinter', {
        'address': address,
      });

      if (result == true) {
        _isConnected = true;
        _connectedAddress = address;
        _connectionType = ConnectionType.bluetooth;
        AppLogger.info('Successfully connected to Bluetooth printer');
        return true;
      } else {
        AppLogger.error('Failed to connect to Bluetooth printer');
        return false;
      }
    } on PlatformException catch (e) {
      AppLogger.error(
          'Platform error connecting to Bluetooth printer: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      AppLogger.error('Error connecting to Bluetooth printer: $e');
      return false;
    }
  }
}
