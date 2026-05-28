import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatMessage {
  final String id;
  final String type; // 'user', 'ai', 'dispatch'
  final String? text;

  ChatMessage({required this.id, required this.type, this.text});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [
    ChatMessage(
      id: '1', 
      type: 'ai', 
      text: 'Hello Priya. I detected a sudden stop. Are you okay?'
    )
  ];

  final List<String> _chips = ["I'm injured", "Need ambulance", "First aid help", "Call police"];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    
    final newMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      type: 'user', 
      text: text
    );
    
    setState(() {
      _messages.add(newMsg);
      _textController.clear();
    });
    
    _scrollToBottom();
    
    // Simulate AI response
    Timer(const Duration(milliseconds: 1500), () {
      final textLower = text.toLowerCase();
      if (textLower.contains('injured') || textLower.contains('ambulance')) {
        setState(() {
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(), 
            type: 'dispatch'
          ));
          _messages.add(ChatMessage(
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(), 
            type: 'ai', 
            text: "I've dispatched an ambulance to your location. Stay calm, help is on the way."
          ));
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(), 
            type: 'ai', 
            text: "I'm alerting nearby stations just in case. Do you need any first aid instructions?"
          ));
        });
      }
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: AppColors.slate950.withOpacity(0.8),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'PRAANA AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Ping indicator
                        _buildPingIndicator(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text('🇮🇳', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Text(
                            'Hindi',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Icon(
                    LucideIcons.mic,
                    color: Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          
          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg.type == 'ai') {
                  return _buildAiMessage(msg);
                } else if (msg.type == 'user') {
                  return _buildUserMessage(msg);
                } else if (msg.type == 'dispatch') {
                  return _buildDispatchMessage(msg);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          
          // Bottom Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.slate950,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick Replies
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _chips.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          label: Text(
                            _chips[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: AppColors.rose500.withOpacity(0.1),
                          side: BorderSide(color: AppColors.rose500.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onPressed: () => _handleSend(_chips[index]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Input Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Type or speak...',
                                  hintStyle: TextStyle(color: AppColors.slate400),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onSubmitted: _handleSend,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.indigo500,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.mic,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _handleSend(_textController.text),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.rose500,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.send,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMessage(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.cyan500.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.cyan500,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: Text(
                msg.text ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Padding on right
        ],
      ),
    );
  }

  Widget _buildUserMessage(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(width: 48), // Padding on left
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                msg.text ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchMessage(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.emerald500.withOpacity(0.2),
              AppColors.emerald500.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.emerald500.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.emerald500.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: AppColors.emerald500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ambulance dispatched!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'ETA: 8 min',
                      style: TextStyle(
                        color: AppColors.emerald400,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to tracking
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                label: const Text('Track Live'),
                icon: const Icon(Icons.arrow_forward, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPingIndicator() {
    return SizedBox(
      width: 8,
      height: 8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 1.0 + (value * 1.5),
                child: Opacity(
                  opacity: 1.0 - value,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cyan500,
                    ),
                  ),
                ),
              );
            },
            onEnd: () {
              // This trick can create a continuous animation without AnimationController
              setState(() {});
            },
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cyan500,
            ),
          ),
        ],
      ),
    );
  }
}
