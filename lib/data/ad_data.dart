import 'dart:io';
import 'package:flutter/foundation.dart';

// 보상형 전면 광고 ID
final REWARD_INTERSTRITIAL_ADID = Platform.isAndroid
    ? (kReleaseMode
            ? 'ca-app-pub-6451550267398782/7774684945' // 실제 광고 ID
            : 'ca-app-pub-3940256099942544/6978759866' // 테스트 광고 ID
        )
    : (kReleaseMode
        ? 'ca-app-pub-6451550267398782/2278815683' // 실제 광고 ID
        : 'ca-app-pub-3940256099942544/6978759866' // 테스트 광고 ID
    );

// 네이티브 광고 ID
final NATIVE_ADID = Platform.isAndroid
    ? (kReleaseMode
            ? 'ca-app-pub-6451550267398782/5238314654' // 실제 광고 ID (여기에 실제 ID를 넣어주세요)
            : 'ca-app-pub-3940256099942544/2247696110' // 테스트 광고 ID
        )
    : (kReleaseMode
        ? 'ca-app-pub-6451550267398782/7396768238' // 실제 광고 ID (여기에 실제 ID를 넣어주세요)
        : 'ca-app-pub-3940256099942544/2247696110' // 테스트 광고 ID
    );
