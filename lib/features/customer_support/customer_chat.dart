import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/shared_widgets/custom_appbar.dart';
import 'package:mego_app/core/shared_widgets/loading_widget.dart';
import '../../core/res/app_colors.dart';
import 'customer_chat_controller.dart';

class CustomerChatView extends StatelessWidget {
  const CustomerChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerChatController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(isBack: true),


      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {

                return LoadingWidget();

              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 80,
                        color: AppColors.socialMediaText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.txtColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start a conversation with our support team',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: AppColors.socialMediaText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMyMessage = controller.isMyMessage(message);

                  return _buildMessageBubble(
                    message: message,
                    isMyMessage: isMyMessage,
                    controller: controller,
                  );
                },
              );
            }),
          ),

          // Message Input Area
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Text Input Field
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 120, // Limit height to prevent overflow
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: controller.messageController,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 15,
                          color: AppColors.txtColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 15,
                            color: AppColors.socialMediaText,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 5,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Send Button
                  Obx(() => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              AppColors.primaryColor.withOpacity(0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: controller.isSending.value
                                ? null
                                : controller.sendMessage,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: controller.isSending.value
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.whiteColor,
                                      ),
                                    )
                                  : Icon(
                                      Icons.send_rounded,
                                      color: AppColors.whiteColor,
                                      size: 24,
                                    ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required message,
    required bool isMyMessage,
    required CustomerChatController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage) ...[
            // Support Agent Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.appSurfaceColor,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: AppColors.whiteColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Message Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: isMyMessage
                    ? LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.appSurfaceColor,
                        ],
                      )
                    : null,
                color: isMyMessage ? null : AppColors.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMyMessage ? 20 : 4),
                  bottomRight: Radius.circular(isMyMessage ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMyMessage
                        ? AppColors.primaryColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: isMyMessage
                          ? AppColors.whiteColor
                          : AppColors.txtColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.formatMessageTime(message.createdAt),
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: isMyMessage
                          ? AppColors.whiteColor.withOpacity(0.7)
                          : AppColors.socialMediaText,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMyMessage) ...[
            const SizedBox(width: 8),
            // User Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.buttonColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.buttonColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.iconColor,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
