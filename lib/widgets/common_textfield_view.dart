import 'package:flutter/material.dart';
import 'package:myapp/utils/text_styles.dart';
import 'package:myapp/utils/themes.dart';

class CommonTextFieldView extends StatelessWidget{
  final String? titleText;
  final String? hintText;
  final String? errorText;
  final bool isObsecureText, isAllowToptitleView;
  final EdgeInsetsGeometry padding;
  final Function(String)? onChanged;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  const CommonTextFieldView (
      {Key? key,
        this.titleText,
        this.hintText,
        this.errorText,
        this.isObsecureText = false,
        this.isAllowToptitleView = true,
        required this.padding,
        this.onChanged,
        required this.keyboardType,
        this.controller})
      :super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAllowToptitleView && titleText !='')
          Padding(
              padding: EdgeInsets.only(left: 16,right: 16,top: 4,bottom: 4),
                  child: Text(
                    titleText ?? "",
                    style: TextStyles(context).getDescriptionStyle(),
                  )
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            shadowColor: Colors.black12.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark ? 0.12 * 0.6 : 0.12 * 0.2
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: SizedBox(
                height: 48,
                child: Center(
                  child: TextField(
                    controller: controller,
                    maxLines: 1,
                    onChanged: onChanged,
                    style: TextStyles(context).getRegularStyle(),
                    obscureText: isObsecureText ,
                    cursorColor: Theme.of(context).primaryColor,
                    onEditingComplete: () {
                      FocusScope.of(context).nextFocus();
                    },
                    decoration: InputDecoration(
                      errorText: null,
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: TextStyle(color: Theme.of(context).disabledColor)),
                    keyboardType: keyboardType,
                  ),
                ),
              ),
            ),
          ),
          if(errorText != null && errorText!.isNotEmpty)
            Padding(
                padding: EdgeInsets.only(left: 16,right: 16,top: 4,bottom: 4),
                child: Text(
                  errorText ?? "",
                  style: TextStyles(context).getDescriptionStyle().copyWith(
                    color: AppTheme.redErrorColor,
                  ),
                )
            ),

        ],
      )
    );
  }
}