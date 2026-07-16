import 'package:flutter/material.dart';
import 'package:haogpt/generated/app_localizations.dart';
import '../widgets/custom_back_button.dart';
import '../core/theme/howai_theme.dart';

class InstructionsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const InstructionsScreen({Key? key, this.onBack}) : super(key: key);

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Determine if we're on a phone or tablet based on width
    final isPhone = MediaQuery.of(context).size.width < 600;

    final List<_InstructionSection> _sections = [
      _InstructionSection(
        title: AppLocalizations.of(context)!.instructionsSection1Title,
        icon: Icons.chat_bubble_outline,
        content: [
          AppLocalizations.of(context)!.instructionsSection1Line1,
          AppLocalizations.of(context)!.instructionsSection1Line2,
          AppLocalizations.of(context)!.instructionsSection1Line3,
          AppLocalizations.of(context)!.instructionsSection1Line4,
          AppLocalizations.of(context)!.instructionsSection1Line5,
        ],
      ),
      _InstructionSection(
        title: AppLocalizations.of(context)!.instructionsSection2Title,
        icon: Icons.image_outlined,
        content: [
          AppLocalizations.of(context)!.instructionsSection2Line1,
          AppLocalizations.of(context)!.instructionsSection2Line2,
          AppLocalizations.of(context)!.instructionsSection2Line3,
          AppLocalizations.of(context)!.instructionsSection2Line4,
          AppLocalizations.of(context)!.instructionsSection2Line5,
        ],
      ),
      _InstructionSection(
        title: AppLocalizations.of(context)!.instructionsSection3Title,
        icon: Icons.brush_outlined,
        content: [
          AppLocalizations.of(context)!.instructionsSection3Line1,
          AppLocalizations.of(context)!.instructionsSection3Line2,
          AppLocalizations.of(context)!.instructionsSection3Line3,
          AppLocalizations.of(context)!.instructionsSection3Line4,
          AppLocalizations.of(context)!.instructionsSection3Line5,
        ],
      ),
      _InstructionSection(
        title: AppLocalizations.of(context)!.instructionsSection4Title,
        icon: Icons.picture_as_pdf,
        content: [
          AppLocalizations.of(context)!.instructionsSection4Line1,
          AppLocalizations.of(context)!.instructionsSection4Line2,
          AppLocalizations.of(context)!.instructionsSection4Line3,
        ],
      ),
      _InstructionSection(
        title: AppLocalizations.of(context)!.instructionsSection5Title,
        icon: Icons.select_all,
        content: [
          AppLocalizations.of(context)!.instructionsSection5Line1,
          AppLocalizations.of(context)!.instructionsSection5Line2,
          AppLocalizations.of(context)!.instructionsSection5Line3,
        ],
      ),
      _InstructionSection(
        title: AppLocalizations.of(context)!.instructionsSection6Title,
        icon: Icons.translate,
        content: [
          AppLocalizations.of(context)!.instructionsSection6Line1,
          AppLocalizations.of(context)!.instructionsSection6Line2,
          AppLocalizations.of(context)!.instructionsSection6Line3,
        ],
      ),
      _InstructionSection(
        title: AppLocalizations.of(context)!.instructionsSection7Title,
        icon: Icons.insights_outlined,
        content: [
          AppLocalizations.of(context)!.instructionsSection7Line1,
          AppLocalizations.of(context)!.instructionsSection7Line2,
          AppLocalizations.of(context)!.instructionsSection7Line3,
          AppLocalizations.of(context)!.instructionsSection7Line4,
          AppLocalizations.of(context)!.instructionsSection7Line5,
        ],
      ),
      _InstructionSection(
        title: AppLocalizations.of(context)!.instructionsSection8Title,
        icon: Icons.privacy_tip_outlined,
        content: [
          AppLocalizations.of(context)!.instructionsSection8Line1,
          AppLocalizations.of(context)!.instructionsSection8Line2,
          AppLocalizations.of(context)!.instructionsSection8Line3,
          AppLocalizations.of(context)!.instructionsSection8Line4,
        ],
      ),
      _InstructionSection(
        title: AppLocalizations.of(context)!.instructionsSection9Title,
        icon: Icons.support_agent,
        content: [
          AppLocalizations.of(context)!.instructionsSection9Line1,
          AppLocalizations.of(context)!.instructionsSection9Line2,
          AppLocalizations.of(context)!.instructionsSection9Line3,
        ],
      ),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.helpAndInstructions,
        onBack: widget.onBack ??
            () {
              Navigator.of(context).pop();
            },
      ),
      // Use different layouts for phone vs tablet
      body: isPhone
          ? _buildPhoneLayout(_sections)
          : _buildTabletLayout(_sections),
    );
  }

  // Phone layout uses a vertical stack with section title and content
  Widget _buildPhoneLayout(List<_InstructionSection> sections) {
    final colors = context.howaiColors;
    return Column(
      children: [
        // Dropdown selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: colors.canvas,
          child: DropdownButtonFormField<int>(
            value: _selectedIndex,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colors.surface,
              hintText: AppLocalizations.of(context)!.discover,
            ),
            icon: Icon(Icons.expand_more_rounded, color: colors.textSecondary),
            elevation: 0,
            isExpanded: true,
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedIndex = newValue;
                });
              }
            },
            items: List.generate(sections.length, (index) {
              return DropdownMenuItem<int>(
                value: index,
                child: Row(
                  children: [
                    Icon(
                      sections[index].icon,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      sections[index].title,
                      style: TextStyle(
                        fontWeight: index == _selectedIndex
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        // Content area (scrollable)
        Expanded(
          child: _buildContentArea(sections),
        ),
      ],
    );
  }

  // Tablet layout uses side-by-side menu and content
  Widget _buildTabletLayout(List<_InstructionSection> sections) {
    final colors = context.howaiColors;
    return Row(
      children: [
        // Left menu
        Container(
          width: 250,
          color: colors.surface,
          child: ListView.builder(
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final selected = index == _selectedIndex;
              return ListTile(
                leading: Icon(
                  sections[index].icon,
                  color: colors.textSecondary,
                ),
                title: Text(
                  sections[index].title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: selected,
                selectedTileColor: colors.surfaceStrong,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              );
            },
          ),
        ),
        // Right content
        Expanded(
          child: _buildContentArea(sections),
        ),
      ],
    );
  }

  // Common content area widget used by both layouts
  Widget _buildContentArea(List<_InstructionSection> sections) {
    final colors = context.howaiColors;
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  sections[_selectedIndex].icon,
                  color: colors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sections[_selectedIndex].title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sections[_selectedIndex].content.asMap().entries.map((entry) {
              final idx = entry.key;
              final line = entry.value;
              if (_selectedIndex == 8 && idx == 1) {
                // Section 9, line 2 (email)
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SelectableText(
                    line,
                    style: TextStyle(
                      color: colors.accent,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  line,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textPrimary,
                    height: 1.45,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _InstructionSection {
  final String title;
  final IconData icon;
  final List<String> content;
  const _InstructionSection(
      {required this.title, required this.icon, required this.content});
}
