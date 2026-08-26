import 'package:flutter/material.dart';

class ServerConfigDialog extends StatefulWidget {
  final String currentUrl;

  const ServerConfigDialog({
    super.key,
    required this.currentUrl,
  });

  static Future<String?> show(BuildContext context, String currentUrl) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => ServerConfigDialog(currentUrl: currentUrl),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late TextEditingController _urlController;
  final String _defaultCloudUrl = 'https://kitchen-os-seven.vercel.app/';
  final String _defaultLocalUrl = 'http://10.0.2.2:3000';

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.currentUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 12,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon & Title
              Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF292524),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.dns_rounded,
                      color: Color(0xFFF5F5F4),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Server Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1917),
                          ),
                        ),
                        Text(
                          'Configure KitchenOS Target Host',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF78716C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Presets Row
              const Text(
                'QUICK PRESETS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF78716C),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  // Cloud Production Preset
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _urlController.text = _defaultCloudUrl;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          color: _urlController.text == _defaultCloudUrl
                              ? const Color(0xFF292524)
                              : const Color(0xFFF5F5F4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE7E5E4)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_done_rounded,
                              size: 20,
                              color: _urlController.text == _defaultCloudUrl
                                  ? const Color(0xFFF5F5F4)
                                  : const Color(0xFF292524),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cloud Prod',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _urlController.text == _defaultCloudUrl
                                    ? const Color(0xFFF5F5F4)
                                    : const Color(0xFF292524),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Local Dev Preset
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _urlController.text = _defaultLocalUrl;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          color: _urlController.text == _defaultLocalUrl
                              ? const Color(0xFF292524)
                              : const Color(0xFFF5F5F4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE7E5E4)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.developer_board_rounded,
                              size: 20,
                              color: _urlController.text == _defaultLocalUrl
                                  ? const Color(0xFFF5F5F4)
                                  : const Color(0xFF292524),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Localhost',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _urlController.text == _defaultLocalUrl
                                    ? const Color(0xFFF5F5F4)
                                    : const Color(0xFF292524),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Custom Input Field
              const Text(
                'TARGET SERVER URL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF78716C),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _urlController,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1C1917),
                ),
                decoration: InputDecoration(
                  hintText: 'https:// or http://192.168.1.x:3000',
                  hintStyle: const TextStyle(color: Color(0xFFA8A29E)),
                  filled: true,
                  fillColor: const Color(0xFFFDFBF7),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE7E5E4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF292524), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Actions Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE7E5E4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF78716C),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final text = _urlController.text.trim();
                        if (text.isNotEmpty) {
                          Navigator.of(context).pop(text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF292524),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Save & Connect',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF5F5F4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
