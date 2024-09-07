import 'dart:io';
import 'package:flutter/foundation.dart';

//  리워드 광고 ID
final INTERSTRITIAL_ADID = Platform.isAndroid
    ? (kReleaseMode
            ? 'ca-app-pub-6451550267398782/4929029758' // 실제 광고 ID
            : 'ca-app-pub-3940256099942544/1033173712' // 테스트 광고 ID
        )
    : (kReleaseMode
        ? 'ca-app-pub-6451550267398782/6964166155' // 실제 광고 ID
        : 'ca-app-pub-3940256099942544/4411468910' // 테스트 광고 ID
    );

final BANNER_ADID = Platform.isAndroid
    ? (kReleaseMode
        ? 'ca-app-pub-6451550267398782/6016237955' // 실제 광고 ID
        : 'ca-app-pub-3940256099942544/6300978111') // 테스트 광고 ID
    : (kReleaseMode
        ? 'ca-app-pub-6451550267398782/8135134833' // 실제 광고 ID
        : 'ca-app-pub-3940256099942544/2934735716'); // 테스트 광고 ID