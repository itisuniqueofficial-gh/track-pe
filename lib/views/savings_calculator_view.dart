import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/neopop_components.dart';
import '../services/mdr_policy.dart';
import '../utils/money.dart';

class SavingsCalculatorView extends StatefulWidget {
  const SavingsCalculatorView({super.key});

  @override
  State<SavingsCalculatorView> createState() => _SavingsCalculatorViewState();
}

class _SavingsCalculatorViewState extends State<SavingsCalculatorView> {
  double _monthlyTurnover = 1500000; // ₹15 Lakhs
  double _avgBillSize = 4500;
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  // Illustrative MDR math computed in integer paise via MdrPolicy.
  int get _monthlyBaseMdrPaise => MdrPolicy.monthlyBaseMdr(
    turnoverPaise: Money.rupeesToPaise(_monthlyTurnover),
    avgBillPaise: Money.rupeesToPaise(_avgBillSize),
  );

  int get _monthlyGstPaise => MdrPolicy.gstOnMdr(_monthlyBaseMdrPaise);

  int get _annualBaseMdrPaise => _monthlyBaseMdrPaise * 12;
  int get _annualGstPaise => _monthlyGstPaise * 12;
  int get _annualMdrPaise => _annualBaseMdrPaise + _annualGstPaise;

  String get _roastCommentary {
    final formatted = Money.formatInr(_annualMdrPaise);
    if (_annualMdrPaise >= 10000000) {
      return '💸 You could be paying about $formatted/yr in illustrative MDR + 18% GST to payment aggregators.';
    } else if (_annualMdrPaise >= 3000000) {
      return '☕ You could be paying about $formatted/yr in illustrative MDR + 18% GST — it adds up fast.';
    } else {
      return '🛡️ Track Pe illustrates how sub-₹2,000 tranche routing could keep this near zero (educational only).';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          NeoPopSurfaceCard(
            backgroundColor: isDark
                ? const Color(0xFF131A2E)
                : const Color(0xFFE8F0FE),
            borderColor: AppColors.primaryBlue,
            depth: 4.0,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    NeoPopPillBadge(
                      label: '0.4% MDR ROAST 🔥',
                      color: AppColors.alertRed,
                      textColor: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Arbitrage Engine',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'HOW MUCH DOES THE NEW MDR COST YOUR BUSINESS?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text(context),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Sliders & Controls Card
          NeoPopSurfaceCard(
            backgroundColor: AppColors.cardBg(context),
            borderColor: AppColors.border(context),
            depth: 4.0,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monthly Turnover Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MONTHLY UPI TURNOVER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.textSub(context),
                      ),
                    ),
                    Text(
                      _currencyFormat.format(_monthlyTurnover),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.goldenYellow,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.goldenYellow,
                    thumbColor: AppColors.goldenYellow,
                    inactiveTrackColor: isDark
                        ? const Color(0xFF27272A)
                        : const Color(0xFFE2E8F0),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _monthlyTurnover,
                    min: 100000,
                    max: 10000000,
                    divisions: 99,
                    onChanged: (val) {
                      setState(() {
                        _monthlyTurnover = val;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // Average Bill Size Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AVERAGE TICKET / BILL SIZE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.textSub(context),
                      ),
                    ),
                    Text(
                      _currencyFormat.format(_avgBillSize),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primaryBlue,
                    thumbColor: AppColors.primaryBlue,
                    inactiveTrackColor: isDark
                        ? const Color(0xFF27272A)
                        : const Color(0xFFE2E8F0),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _avgBillSize,
                    min: 500,
                    max: 50000,
                    divisions: 99,
                    onChanged: (val) {
                      setState(() {
                        _avgBillSize = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Output Numbers: Annual MDR Loss vs Track Pe Savings
          Row(
            children: [
              // Loss Box
              Expanded(
                child: NeoPopSurfaceCard(
                  backgroundColor: isDark
                      ? const Color(0xFF251016)
                      : const Color(0xFFFFF0F2),
                  borderColor: AppColors.alertRed,
                  depth: 3.0,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ANNUAL GATEWAY LOSS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.alertRed,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Money.formatInr(_annualMdrPaise),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.alertRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Paid to banks/aggregators',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.textMuted
                              : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Track Pe 0% MDR Box
              Expanded(
                child: NeoPopSurfaceCard(
                  backgroundColor: isDark
                      ? const Color(0xFF0C1B2E)
                      : const Color(0xFFF0F7FF),
                  borderColor: AppColors.primaryBlue,
                  depth: 3.0,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TRACK PE SAVINGS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Money.formatInr(_annualMdrPaise),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '100% Retained via 0% MDR',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.textMuted
                              : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (_annualMdrPaise > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.chipBg(context),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 14,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '0.4% Base MDR: ${Money.formatInr(_annualBaseMdrPaise)}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text(context),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '+ 18% GST: ${Money.formatInr(_annualGstPaise)}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.alertRed,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Roast Commentary Box
          NeoPopSurfaceCard(
            backgroundColor: AppColors.cardBg(context),
            borderColor: AppColors.goldenYellow,
            depth: 3.0,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ROAST OF THE DAY 🎙️',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: AppColors.goldenYellow,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _roastCommentary,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Viral Clout Share Button
          NeoPopActionButton(
            text: 'TWEET THIS MDR ROAST ON X 🔥',
            color: isDark ? Colors.white : AppColors.primaryBlue,
            textColor: isDark ? Colors.black : Colors.white,
            prefixIcon: Icon(
              Icons.send_rounded,
              color: isDark ? Colors.black : Colors.white,
              size: 16,
            ),
            onTap: () {
              final tweet =
                  '🚨 I calculated how much the new 0.4% UPI MDR + 18% GST is costing my business:\n\n'
                  '💸 Total Loss: ${Money.formatInr(_annualMdrPaise)}/year to payment aggregators!\n'
                  '🛡️ Track Pe illustrates sub-₹2,000 tranche routing (educational demo, no real settlement).\n\n'
                  '#Fintech #UPI #TrackPe';
              final url = Uri.parse(
                'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(tweet)}',
              );
              launchUrl(url, mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }
}
