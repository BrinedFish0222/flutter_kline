package com.example.example_java_kline.example;

import java.util.ArrayList;
import java.util.List;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.TypeReference;

// 导入必要的 Java 包...

public class ExampleMinuteData {

    private static final String lineDataJson = "[\r\n" + //
            "    [20230906, 0, 0, 0, 0, 11.34, 19688, 0, 930],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.36, 5193, 0, 931],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 5042, 0, 932],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.35, 2928, 0, 933],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 3122, 0, 934],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.36, 4146, 0, 935],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 10068, 0, 936],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 3216, 0, 937],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 1960, 0, 938],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.35, 3547, 0, 939],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.36, 2117, 0, 940],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 2260, 0, 941],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.34, 9382, 0, 942],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.35, 2442, 0, 943],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.34, 2076, 0, 944],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 3464, 0, 945],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.36, 4146, 0, 946],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.37, 2546, 0, 947],\r\n" + //
            "    [20230906, 11.37, 0, 0, 0, 11.37, 1671, 0, 948],\r\n" + //
            "    [20230906, 11.37, 0, 0, 0, 11.35, 7749, 0, 949],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 5672, 0, 950],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.34, 2452, 0, 951],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 2126, 0, 952],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.35, 3392, 0, 953],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 3596, 0, 954],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.33, 1442, 0, 955],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 3850, 0, 956],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.34, 1859, 0, 957],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 1160, 0, 958],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 3637, 0, 959],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.33, 4248, 0, 1000],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.34, 905, 0, 1001],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 2340, 0, 1002],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.33, 2218, 0, 1003],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.34, 909, 0, 1004],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.31, 15044, 0, 1005],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.3, 16609, 0, 1006],\r\n" + //
            "    [20230906, 11.3, 0, 0, 0, 11.33, 12277, 0, 1007],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.31, 2546, 0, 1008],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.32, 585, 0, 1009],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 4967, 0, 1010],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 816, 0, 1011],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.31, 3263, 0, 1012],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.32, 3312, 0, 1013],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 671, 0, 1014],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 1909, 0, 1015],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.31, 6635, 0, 1016],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.32, 1136, 0, 1017],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 1838, 0, 1018],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 2122, 0, 1019],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 933, 0, 1020],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 1851, 0, 1021],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 680, 0, 1022],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.34, 2234, 0, 1023],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 2161, 0, 1024],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.33, 1003, 0, 1025],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.34, 718, 0, 1026],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 1602, 0, 1027],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.33, 1171, 0, 1028],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 2629, 0, 1029],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 1920, 0, 1030],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 1506, 0, 1031],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 859, 0, 1032],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 286, 0, 1033],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 999, 0, 1034],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 1491, 0, 1035],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 1056, 0, 1036],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 2614, 0, 1037],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 558, 0, 1038],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 591, 0, 1039],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 2270, 0, 1040],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 3269, 0, 1041],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.34, 736, 0, 1042],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.33, 1070, 0, 1043],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 1267, 0, 1044],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.34, 669, 0, 1045],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 436, 0, 1046],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 2639, 0, 1047],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 1679, 0, 1048],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.33, 424, 0, 1049],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 4684, 0, 1050],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 400, 0, 1051],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 480, 0, 1052],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 434, 0, 1053],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 834, 0, 1054],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 404, 0, 1055],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 689, 0, 1056],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 706, 0, 1057],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 794, 0, 1058],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 1334, 0, 1059],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 602, 0, 1100],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 1386, 0, 1101],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 6959, 0, 1102],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 1638, 0, 1103],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.31, 927, 0, 1104],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.32, 752, 0, 1105],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 818, 0, 1106],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.31, 1130, 0, 1107],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 11372, 0, 1108],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 3743, 0, 1109],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 2221, 0, 1110],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.3, 1548, 0, 1111],\r\n" + //
            "    [20230906, 11.3, 0, 0, 0, 11.3, 3139, 0, 1112],\r\n" + //
            "    [20230906, 11.3, 0, 0, 0, 11.3, 1546, 0, 1113],\r\n" + //
            "    [20230906, 11.3, 0, 0, 0, 11.31, 1480, 0, 1114],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 218, 0, 1115],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.32, 752, 0, 1116],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.31, 529, 0, 1117],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 2784, 0, 1118],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 576, 0, 1119],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.32, 1141, 0, 1120],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 734, 0, 1121],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 698, 0, 1122],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.31, 842, 0, 1123],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 1022, 0, 1124],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.33, 3877, 0, 1125],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 821, 0, 1126],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 1009, 0, 1127],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 1408, 0, 1128],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 1443, 0, 1129],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.34, 6001, 0, 1300],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.35, 1679, 0, 1301],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.36, 2073, 0, 1302],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.37, 6406, 0, 1303],\r\n" + //
            "    [20230906, 11.37, 0, 0, 0, 11.36, 1686, 0, 1304],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.35, 1420, 0, 1305],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 506, 0, 1306],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 429, 0, 1307],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 1459, 0, 1308],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.34, 1665, 0, 1309],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.36, 2804, 0, 1310],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.35, 908, 0, 1311],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.34, 146, 0, 1312],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.35, 1428, 0, 1313],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 1070, 0, 1314],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.36, 942, 0, 1315],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.35, 1038, 0, 1316],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 683, 0, 1317],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 1132, 0, 1318],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.36, 2261, 0, 1319],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 612, 0, 1320],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 2116, 0, 1321],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.35, 622, 0, 1322],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 4308, 0, 1323],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.36, 1568, 0, 1324],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 1082, 0, 1325],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 1081, 0, 1326],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.38, 2639, 0, 1327],\r\n" + //
            "    [20230906, 11.38, 0, 0, 0, 11.37, 1241, 0, 1328],\r\n" + //
            "    [20230906, 11.37, 0, 0, 0, 11.38, 2061, 0, 1329],\r\n" + //
            "    [20230906, 11.38, 0, 0, 0, 11.37, 2087, 0, 1330],\r\n" + //
            "    [20230906, 11.37, 0, 0, 0, 11.37, 2503, 0, 1331],\r\n" + //
            "    [20230906, 11.37, 0, 0, 0, 11.38, 1588, 0, 1332],\r\n" + //
            "    [20230906, 11.38, 0, 0, 0, 11.4, 6890, 0, 1333],\r\n" + //
            "    [20230906, 11.4, 0, 0, 0, 11.41, 3194, 0, 1334],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.41, 3170, 0, 1335],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.42, 6873, 0, 1336],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 10514, 0, 1337],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.41, 1920, 0, 1338],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.43, 3911, 0, 1339],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.42, 2990, 0, 1340],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.43, 3000, 0, 1341],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.42, 2097, 0, 1342],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 762, 0, 1343]\r\n" + //
            "  ]";
    private static final String lineData2Json = "[\r\n" + //
            "    [20230906, 0, 0, 0, 0, 11.34, 19688, 0, 930],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.36, 5193, 0, 931],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 5042, 0, 932],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.35, 2928, 0, 933],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 3122, 0, 934],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.36, 4146, 0, 935],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 10068, 0, 936],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 3216, 0, 937],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 1960, 0, 938],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.35, 3547, 0, 939],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.36, 2117, 0, 940],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 2260, 0, 941],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.34, 9382, 0, 942],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.35, 2442, 0, 943],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.34, 2076, 0, 944],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 3464, 0, 945],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.36, 4146, 0, 946],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.37, 2546, 0, 947],\r\n" + //
            "    [20230906, 11.37, 0, 0, 0, 11.37, 1671, 0, 948],\r\n" + //
            "    [20230906, 11.37, 0, 0, 0, 11.35, 7749, 0, 949],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 5672, 0, 950],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.34, 2452, 0, 951],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 2126, 0, 952],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.35, 3392, 0, 953],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 3596, 0, 954],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.33, 1442, 0, 955],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 3850, 0, 956],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.34, 1859, 0, 957],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 1160, 0, 958],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 3637, 0, 959],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.33, 4248, 0, 1000],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.34, 905, 0, 1001],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 2340, 0, 1002],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.33, 2218, 0, 1003],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.34, 909, 0, 1004],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.31, 15044, 0, 1005],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.3, 16609, 0, 1006],\r\n" + //
            "    [20230906, 11.3, 0, 0, 0, 11.33, 12277, 0, 1007],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.31, 2546, 0, 1008],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.32, 585, 0, 1009],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 4967, 0, 1010],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 816, 0, 1011],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.31, 3263, 0, 1012],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.32, 3312, 0, 1013],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 671, 0, 1014],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 1909, 0, 1015],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.31, 6635, 0, 1016],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.32, 1136, 0, 1017],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 1838, 0, 1018],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 2122, 0, 1019],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 933, 0, 1020],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 1851, 0, 1021],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 680, 0, 1022],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.34, 2234, 0, 1023],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 2161, 0, 1024],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.33, 1003, 0, 1025],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.34, 718, 0, 1026],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 1602, 0, 1027],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.33, 1171, 0, 1028],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 2629, 0, 1029],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 1920, 0, 1030],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 1506, 0, 1031],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 859, 0, 1032],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 286, 0, 1033],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 999, 0, 1034],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 1491, 0, 1035],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 1056, 0, 1036],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 2614, 0, 1037],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 558, 0, 1038],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 591, 0, 1039],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 2270, 0, 1040],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 3269, 0, 1041],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.34, 736, 0, 1042],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.33, 1070, 0, 1043],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 1267, 0, 1044],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.34, 669, 0, 1045],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 436, 0, 1046],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 2639, 0, 1047],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.34, 1679, 0, 1048],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.33, 424, 0, 1049],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 4684, 0, 1050],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 400, 0, 1051],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 480, 0, 1052],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 434, 0, 1053],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 834, 0, 1054],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 404, 0, 1055],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 689, 0, 1056],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 706, 0, 1057],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 794, 0, 1058],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 1334, 0, 1059],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 602, 0, 1100],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 1386, 0, 1101],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 6959, 0, 1102],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 1638, 0, 1103],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.31, 927, 0, 1104],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.32, 752, 0, 1105],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 818, 0, 1106],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.31, 1130, 0, 1107],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 11372, 0, 1108],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 3743, 0, 1109],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 2221, 0, 1110],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.3, 1548, 0, 1111],\r\n" + //
            "    [20230906, 11.3, 0, 0, 0, 11.3, 3139, 0, 1112],\r\n" + //
            "    [20230906, 11.3, 0, 0, 0, 11.3, 1546, 0, 1113],\r\n" + //
            "    [20230906, 11.3, 0, 0, 0, 11.31, 1480, 0, 1114],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 218, 0, 1115],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.32, 752, 0, 1116],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.31, 529, 0, 1117],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 2784, 0, 1118],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 576, 0, 1119],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.32, 1141, 0, 1120],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 734, 0, 1121],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 698, 0, 1122],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.31, 842, 0, 1123],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.31, 1022, 0, 1124],\r\n" + //
            "    [20230906, 11.31, 0, 0, 0, 11.33, 3877, 0, 1125],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.33, 821, 0, 1126],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.32, 1009, 0, 1127],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.32, 1408, 0, 1128],\r\n" + //
            "    [20230906, 11.32, 0, 0, 0, 11.33, 1443, 0, 1129],\r\n" + //
            "    [20230906, 11.33, 0, 0, 0, 11.34, 6001, 0, 1300],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.35, 1679, 0, 1301],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.36, 2073, 0, 1302],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.37, 6406, 0, 1303],\r\n" + //
            "    [20230906, 11.37, 0, 0, 0, 11.36, 1686, 0, 1304],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.35, 1420, 0, 1305],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 506, 0, 1306],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 429, 0, 1307],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 1459, 0, 1308],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.34, 1665, 0, 1309],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.36, 2804, 0, 1310],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.35, 908, 0, 1311],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.34, 146, 0, 1312],\r\n" + //
            "    [20230906, 11.34, 0, 0, 0, 11.35, 1428, 0, 1313],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 1070, 0, 1314],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.36, 942, 0, 1315],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.35, 1038, 0, 1316],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 683, 0, 1317],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 1132, 0, 1318],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.36, 2261, 0, 1319],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 612, 0, 1320],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 2116, 0, 1321],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.35, 622, 0, 1322],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.35, 4308, 0, 1323],\r\n" + //
            "    [20230906, 11.35, 0, 0, 0, 11.36, 1568, 0, 1324],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 1082, 0, 1325],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.36, 1081, 0, 1326],\r\n" + //
            "    [20230906, 11.36, 0, 0, 0, 11.38, 2639, 0, 1327],\r\n" + //
            "    [20230906, 11.38, 0, 0, 0, 11.37, 1241, 0, 1328],\r\n" + //
            "    [20230906, 11.37, 0, 0, 0, 11.38, 2061, 0, 1329],\r\n" + //
            "    [20230906, 11.38, 0, 0, 0, 11.37, 2087, 0, 1330],\r\n" + //
            "    [20230906, 11.37, 0, 0, 0, 11.37, 2503, 0, 1331],\r\n" + //
            "    [20230906, 11.37, 0, 0, 0, 11.38, 1588, 0, 1332],\r\n" + //
            "    [20230906, 11.38, 0, 0, 0, 11.4, 6890, 0, 1333],\r\n" + //
            "    [20230906, 11.4, 0, 0, 0, 11.41, 3194, 0, 1334],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.41, 3170, 0, 1335],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.42, 6873, 0, 1336],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 10514, 0, 1337],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.41, 1920, 0, 1338],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.43, 3911, 0, 1339],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.42, 2990, 0, 1340],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.43, 3000, 0, 1341],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.42, 2097, 0, 1342],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 2105, 0, 1343],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 5385, 0, 1344],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 3680, 0, 1345],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.41, 6477, 0, 1346],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.41, 4643, 0, 1347],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.41, 2471, 0, 1348],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.42, 1812, 0, 1349],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.41, 1713, 0, 1350],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.42, 4171, 0, 1351],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 3144, 0, 1352],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 1894, 0, 1353],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.43, 1747, 0, 1354],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.41, 1483, 0, 1355],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.41, 579, 0, 1356],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.41, 715, 0, 1357],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.41, 1075, 0, 1358],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.42, 1111, 0, 1359],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.43, 8634, 0, 1400],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.43, 1917, 0, 1401],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.42, 3157, 0, 1402],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 2583, 0, 1403],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.43, 1859, 0, 1404],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.43, 2039, 0, 1405],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.42, 11054, 0, 1406],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 4201, 0, 1407],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 1475, 0, 1408],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 1509, 0, 1409],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 726, 0, 1410],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.41, 2620, 0, 1411],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.42, 1080, 0, 1412],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.41, 833, 0, 1413],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.42, 1050, 0, 1414],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.41, 799, 0, 1415],\r\n" + //
            "    [20230906, 11.41, 0, 0, 0, 11.43, 2378, 0, 1416],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.43, 1826, 0, 1417],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.42, 1907, 0, 1418],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 1730, 0, 1419],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 1440, 0, 1420],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.43, 10523, 0, 1421],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.44, 1510, 0, 1422],\r\n" + //
            "    [20230906, 11.44, 0, 0, 0, 11.43, 1587, 0, 1423],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.43, 2112, 0, 1424],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.43, 1884, 0, 1425],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.44, 2276, 0, 1426],\r\n" + //
            "    [20230906, 11.44, 0, 0, 0, 11.43, 2761, 0, 1427],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.45, 7014, 0, 1428],\r\n" + //
            "    [20230906, 11.45, 0, 0, 0, 11.45, 9946, 0, 1429],\r\n" + //
            "    [20230906, 11.45, 0, 0, 0, 11.45, 4927, 0, 1430],\r\n" + //
            "    [20230906, 11.45, 0, 0, 0, 11.45, 850, 0, 1431],\r\n" + //
            "    [20230906, 11.45, 0, 0, 0, 11.46, 3941, 0, 1432],\r\n" + //
            "    [20230906, 11.46, 0, 0, 0, 11.45, 3277, 0, 1433],\r\n" + //
            "    [20230906, 11.45, 0, 0, 0, 11.44, 580, 0, 1434],\r\n" + //
            "    [20230906, 11.44, 0, 0, 0, 11.45, 2042, 0, 1435],\r\n" + //
            "    [20230906, 11.45, 0, 0, 0, 11.44, 6923, 0, 1436],\r\n" + //
            "    [20230906, 11.44, 0, 0, 0, 11.44, 1633, 0, 1437],\r\n" + //
            "    [20230906, 11.44, 0, 0, 0, 11.44, 938, 0, 1438],\r\n" + //
            "    [20230906, 11.44, 0, 0, 0, 11.44, 976, 0, 1439],\r\n" + //
            "    [20230906, 11.44, 0, 0, 0, 11.43, 4613, 0, 1440],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.43, 862, 0, 1441],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.42, 577, 0, 1442],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 933, 0, 1443],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 1036, 0, 1444],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.44, 6553, 0, 1445],\r\n" + //
            "    [20230906, 11.44, 0, 0, 0, 11.42, 2845, 0, 1446],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.43, 468, 0, 1447],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.42, 2492, 0, 1448],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 1104, 0, 1449],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 874, 0, 1450],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 1200, 0, 1451],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 1174, 0, 1452],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.43, 2892, 0, 1453],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.42, 4094, 0, 1454],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.42, 2836, 0, 1455],\r\n" + //
            "    [20230906, 11.42, 0, 0, 0, 11.43, 5712, 0, 1456],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.43, 24, 0, 1457],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.43, 0, 0, 1458],\r\n" + //
            "    [20230906, 11.43, 0, 0, 0, 11.43, 6533, 0, 1459]\r\n" + //
            "  ]";

    private static String a1Json = "[11.388675833929625,11.386302604328582,11.385057983591887,11.380180330041474,11.382257696776962,11.377567801160042,11.380260590548358,11.380109467097457,11.382223921199241,11.377710204476037,11.380258184596114,11.37623904789318,11.373524026937103,11.370098964686127,11.365305820811685,11.364794004536398,11.365986618825298,11.364228463785103,11.361224321932754,11.364237704996738,11.365016920315808,11.364161508782066,11.359169609150973,11.356798137187909,11.359968380608787,11.359022326847326,11.359431250518508,11.363085425887787,11.363303539615048,11.363928089088153,11.367780224581873,11.366864706458543,11.371126962824315,11.372680309878533,11.376510977422402,11.379481394052576,11.377322358750035,11.374681676633255,11.373746931621673,11.373771010468076,11.376385699035438,11.3728532875844,11.371664800361076,11.37456291008729,11.37060777978644,11.369274412466801,11.368047485142887,11.370949060940346,11.370287407567634,11.366499887233436,11.367170360567645,11.36454209268744,11.361872434007543,11.362079435377709,11.359689293876192,11.360572012065566,11.364362323987905,11.361467536526135,11.364489873777258,11.365926081401538,11.367100495031693,11.366219710582504,11.36360116918814,11.363007633283424,11.359663316688396,11.36093027151583,11.363043538438049,11.363882202194771,11.366629880794232,11.362824655533425,11.365643899464516,11.365812496224882,11.36744493918082,11.372145601877895,11.3703616157645,11.366040519921258,11.37025218074087,11.375190555584924,11.374711368656275,11.373254458677392,11.376676729164636,11.376318983985028,11.378223845814446,11.375797903638917,11.371534017997135,11.373035748924886,11.372215636770045,11.371308866030644,11.368176557732527,11.3688711989899,11.373462481428339,11.376394474436335,11.377233039329683,11.372428440844917,11.372364288289356,11.372860303139747,11.369803920727568,11.374345281936657,11.372674647985122,11.37505767192293,11.378032667840984,11.381453718096688,11.381897807364208,11.38448376975588,11.383679932045816,11.379916324523379,11.378286291107566,11.3825695492335,11.37997049355978,11.375940308708413,11.372066625979118,11.375867182581404,11.380586497540198,11.384784167558436,11.389176049692649,11.384948402091638,11.383865062780222,11.380619946961298,11.377031974329341,11.380462582414673,11.376133080043804,11.375694138195511,11.379166758970113,11.375305610081574,11.370978851062151,11.37570140831496,11.378440277327286,11.37660670810722,11.3762120562133,11.375368531899788,11.376661020001462,11.376000954495506,11.371593045267629,11.36966683274629,11.367180262678227,11.371061704308051,11.369399602982845,11.368344714042058,11.368285451274954,11.36434143333345,11.364239507557171,11.36023795262189,11.36266214208173,11.365313053133276,11.369888057544742,11.370170674980914,11.3720157737007,11.372911410289454,11.370109581215878,11.372190837368718,11.371406453454126,11.36889794080043,11.370481751449052,11.374063209776102,11.377582984070873,11.380823027357424,11.383036651401387,11.387037830614464,11.389575744575675,11.390087496836767,11.389321643897608,11.388020039391526,11.385769501318457,11.387569010716025,11.386658023970362,11.385688986782563,11.389142209695121,11.385026653958304,11.384550635504269,11.384666001244804,11.38728400870485,11.38877832294567,11.388805867460702,11.385105667095948,11.383012316285763,11.381044463674069,11.378925260954079,11.374227174252749,11.375116603944166,11.371757783440426,11.367079367955398,11.362598854536667,11.365225507612974,11.361659693308779,11.364088183088448,11.36371108592126,11.366654893978957,11.37037472188963,11.366966651890516,11.366457280890415,11.365258124791788,11.367288003432648,11.362811659312282,11.359490715764128,11.360780794089061,11.35947780295594,11.360897997419038,11.357262937521304,11.354711990988866,11.351593006053434,11.349698098859692,11.352628227420936,11.348979862781489,11.353050390731019,11.348226415921397,11.348941865332426,11.351673576945853,11.355400181639656,11.351780379874187,11.351909965991892,11.347941646875844,11.35218029606038,11.350010981700196,11.34770705964009,11.348607196548913,11.349964737840075,11.34802792279194,11.3520501729025,11.34923737099219,11.351086340306752,11.355694344159568,11.355750842362403,11.35175374915542,11.35402567449476,11.352005768922947,11.352316970293883,11.3571465654491,11.352891958628119,11.348282802338735,11.344885349903116,11.345616109269557,11.341151312220797,11.345168308572614,11.348579798630851,11.343673604089377,11.347307329143387,11.345993462920312,11.348208385845156,11.351704295152532,11.349096643119942]";

    public static int index = 0;
    public static List<List<Double>> lineData = new ArrayList<>();
    public static List<List<Double>> lineData2 = new ArrayList<>();
    public static List<Double> a1 = new ArrayList<>();

    static {
        lineData = JSON.parseObject(lineDataJson, new TypeReference<List<List<Double>>>() {
        });
        lineData2 = JSON.parseObject(lineData2Json, new TypeReference<List<List<Double>>>() {
        });
        a1 = JSON.parseObject(a1Json, new TypeReference<List<Double>>() {
        });
    }

}
