import Foundation

struct ChinaCityData {
    struct City: Identifiable {
        let id = UUID()
        let province: String
        let name: String
        let longitude: Double
        let latitude: Double
    }

    // 使用中性的"地区"命名，避免政治敏感
    // 按地理位置分组，不涉及主权归属问题
    static func getRegions(language: AppLanguage) -> [String] {
        switch language {
        case .simplifiedChinese:
            return ["中国大陆", "台湾", "香港", "澳门", "马来西亚", "新加坡"]
        case .traditionalChinese:
            return ["中國大陸", "台灣", "香港", "澳門", "馬來西亞", "新加坡"]
        case .english:
            return ["Mainland China", "Taiwan", "Hong Kong", "Macau", "Malaysia", "Singapore"]
        }
    }

    static let mainlandProvinces = [
        // 华北
        "北京", "天津", "河北", "山西", "内蒙古",
        // 东北
        "辽宁", "吉林", "黑龙江",
        // 华东
        "上海", "江苏", "浙江", "安徽", "福建", "江西", "山东",
        // 华中
        "河南", "湖北", "湖南",
        // 华南
        "广东", "广西", "海南",
        // 西南
        "重庆", "四川", "贵州", "云南", "西藏",
        // 西北
        "陕西", "甘肃", "青海", "宁夏", "新疆"
    ]

    // Keep for backward compatibility if needed, or computed property
    static var provinces: [String] { mainlandProvinces + ["臺灣", "香港", "澳門", "新加坡", "马来西亚"] }

    static func getDataKey(for region: String, language: AppLanguage) -> String {
        // Map display name to data key
        switch language {
        case .simplifiedChinese:
            switch region {
            case "台湾": return "臺灣"
            case "澳门": return "澳門"
            case "中国大陆": return "中国大陆"
            default: return region
            }
        case .traditionalChinese:
            switch region {
            case "中國大陸": return "中国大陆"
            case "台灣": return "臺灣"
            case "澳門": return "澳門"
            case "馬來西亞": return "马来西亚"
            default: return region
            }
        case .english:
            switch region {
            case "Mainland China": return "中国大陆"
            case "Taiwan": return "臺灣"
            case "Hong Kong": return "香港"
            case "Macau": return "澳門"
            case "Malaysia": return "马来西亚"
            case "Singapore": return "新加坡"
            default: return region
            }
        }
    }

    static let cities: [String: [City]] = [
        "北京": [
            City(province: "北京", name: "北京市", longitude: 116.4074, latitude: 39.9042)
        ],
        "天津": [
            City(province: "天津", name: "天津市", longitude: 117.2008, latitude: 39.0842)
        ],
        "上海": [
            City(province: "上海", name: "上海市", longitude: 121.4737, latitude: 31.2304)
        ],
        "重庆": [
            City(province: "重庆", name: "重庆市", longitude: 106.5516, latitude: 29.5630)
        ],
        "河北": [
            City(province: "河北", name: "石家庄市", longitude: 114.5149, latitude: 38.0428),
            City(province: "河北", name: "唐山市", longitude: 118.1752, latitude: 39.6304),
            City(province: "河北", name: "秦皇岛市", longitude: 119.5993, latitude: 39.9354),
            City(province: "河北", name: "邯郸市", longitude: 114.5391, latitude: 36.6255),
            City(province: "河北", name: "邢台市", longitude: 114.5048, latitude: 37.0682),
            City(province: "河北", name: "保定市", longitude: 115.4637, latitude: 38.8738),
            City(province: "河北", name: "张家口市", longitude: 114.8869, latitude: 40.8113),
            City(province: "河北", name: "承德市", longitude: 117.9634, latitude: 40.9522),
            City(province: "河北", name: "沧州市", longitude: 116.8387, latitude: 38.3037),
            City(province: "河北", name: "廊坊市", longitude: 116.7048, latitude: 39.5377),
            City(province: "河北", name: "衡水市", longitude: 115.6709, latitude: 37.7388)
        ],
        "山西": [
            City(province: "山西", name: "太原市", longitude: 112.5489, latitude: 37.8706),
            City(province: "山西", name: "大同市", longitude: 113.3001, latitude: 40.0769),
            City(province: "山西", name: "阳泉市", longitude: 113.5830, latitude: 37.8570),
            City(province: "山西", name: "长治市", longitude: 113.1163, latitude: 36.1951),
            City(province: "山西", name: "晋城市", longitude: 112.8513, latitude: 35.4901),
            City(province: "山西", name: "朔州市", longitude: 112.4328, latitude: 39.3313),
            City(province: "山西", name: "晋中市", longitude: 112.7536, latitude: 37.6872),
            City(province: "山西", name: "运城市", longitude: 111.0073, latitude: 35.0228),
            City(province: "山西", name: "忻州市", longitude: 112.7344, latitude: 38.4163),
            City(province: "山西", name: "临汾市", longitude: 111.5189, latitude: 36.0881),
            City(province: "山西", name: "吕梁市", longitude: 111.1344, latitude: 37.5177)
        ],
        "内蒙古": [
            City(province: "内蒙古", name: "呼和浩特市", longitude: 111.6708, latitude: 40.8183),
            City(province: "内蒙古", name: "包头市", longitude: 109.8403, latitude: 40.6581),
            City(province: "内蒙古", name: "乌海市", longitude: 106.7944, latitude: 39.6736),
            City(province: "内蒙古", name: "赤峰市", longitude: 118.8869, latitude: 42.2586),
            City(province: "内蒙古", name: "通辽市", longitude: 122.2438, latitude: 43.6174),
            City(province: "内蒙古", name: "鄂尔多斯市", longitude: 109.7810, latitude: 39.6086),
            City(province: "内蒙古", name: "呼伦贝尔市", longitude: 119.7658, latitude: 49.2114),
            City(province: "内蒙古", name: "巴彦淖尔市", longitude: 107.3874, latitude: 40.7574),
            City(province: "内蒙古", name: "乌兰察布市", longitude: 113.1328, latitude: 41.0347)
        ],
        "辽宁": [
            City(province: "辽宁", name: "沈阳市", longitude: 123.4328, latitude: 41.8045),
            City(province: "辽宁", name: "大连市", longitude: 121.6147, latitude: 38.9140),
            City(province: "辽宁", name: "鞍山市", longitude: 122.9946, latitude: 41.1089),
            City(province: "辽宁", name: "抚顺市", longitude: 123.9574, latitude: 41.8801),
            City(province: "辽宁", name: "本溪市", longitude: 123.7703, latitude: 41.2979),
            City(province: "辽宁", name: "丹东市", longitude: 124.3541, latitude: 40.1290),
            City(province: "辽宁", name: "锦州市", longitude: 121.1269, latitude: 41.0954),
            City(province: "辽宁", name: "营口市", longitude: 122.2352, latitude: 40.6674),
            City(province: "辽宁", name: "阜新市", longitude: 121.6708, latitude: 42.0220),
            City(province: "辽宁", name: "辽阳市", longitude: 123.2373, latitude: 41.2694),
            City(province: "辽宁", name: "盘锦市", longitude: 122.0697, latitude: 41.1245),
            City(province: "辽宁", name: "铁岭市", longitude: 123.7261, latitude: 42.2236),
            City(province: "辽宁", name: "朝阳市", longitude: 120.4505, latitude: 41.5765),
            City(province: "辽宁", name: "葫芦岛市", longitude: 120.8370, latitude: 40.7113)
        ],
        "吉林": [
            City(province: "吉林", name: "长春市", longitude: 125.3235, latitude: 43.8171),
            City(province: "吉林", name: "吉林市", longitude: 126.5494, latitude: 43.8381),
            City(province: "吉林", name: "四平市", longitude: 124.3505, latitude: 43.1666),
            City(province: "吉林", name: "辽源市", longitude: 125.1437, latitude: 42.8876),
            City(province: "吉林", name: "通化市", longitude: 125.9398, latitude: 41.7285),
            City(province: "吉林", name: "白山市", longitude: 126.4142, latitude: 41.9425),
            City(province: "吉林", name: "松原市", longitude: 124.8256, latitude: 45.1361),
            City(province: "吉林", name: "白城市", longitude: 122.8410, latitude: 45.6196),
            City(province: "吉林", name: "延边朝鲜族自治州", longitude: 129.5131, latitude: 42.8914)
        ],
        "黑龙江": [
            City(province: "黑龙江", name: "哈尔滨市", longitude: 126.6433, latitude: 45.7566),
            City(province: "黑龙江", name: "齐齐哈尔市", longitude: 123.9180, latitude: 47.3543),
            City(province: "黑龙江", name: "鸡西市", longitude: 130.9697, latitude: 45.2950),
            City(province: "黑龙江", name: "鹤岗市", longitude: 130.2977, latitude: 47.3500),
            City(province: "黑龙江", name: "双鸭山市", longitude: 131.1589, latitude: 46.6434),
            City(province: "黑龙江", name: "大庆市", longitude: 125.1033, latitude: 46.5895),
            City(province: "黑龙江", name: "伊春市", longitude: 128.8414, latitude: 47.7278),
            City(province: "黑龙江", name: "佳木斯市", longitude: 130.3185, latitude: 46.7994),
            City(province: "黑龙江", name: "七台河市", longitude: 131.0032, latitude: 45.7711),
            City(province: "黑龙江", name: "牡丹江市", longitude: 129.6330, latitude: 44.5525),
            City(province: "黑龙江", name: "黑河市", longitude: 127.5286, latitude: 50.2442),
            City(province: "黑龙江", name: "绥化市", longitude: 126.9694, latitude: 46.6384),
            City(province: "黑龙江", name: "大兴安岭地区", longitude: 124.1965, latitude: 52.3353)
        ],
        "江苏": [
            City(province: "江苏", name: "南京市", longitude: 118.7969, latitude: 32.0603),
            City(province: "江苏", name: "无锡市", longitude: 120.3019, latitude: 31.5747),
            City(province: "江苏", name: "徐州市", longitude: 117.2838, latitude: 34.2044),
            City(province: "江苏", name: "常州市", longitude: 119.9740, latitude: 31.8109),
            City(province: "江苏", name: "苏州市", longitude: 120.5853, latitude: 31.2989),
            City(province: "江苏", name: "南通市", longitude: 120.8943, latitude: 31.9809),
            City(province: "江苏", name: "连云港市", longitude: 119.2216, latitude: 34.5967),
            City(province: "江苏", name: "淮安市", longitude: 119.1130, latitude: 33.6104),
            City(province: "江苏", name: "盐城市", longitude: 120.1633, latitude: 33.3475),
            City(province: "江苏", name: "扬州市", longitude: 119.4127, latitude: 32.3912),
            City(province: "江苏", name: "镇江市", longitude: 119.4248, latitude: 32.1877),
            City(province: "江苏", name: "泰州市", longitude: 119.9229, latitude: 32.4569),
            City(province: "江苏", name: "宿迁市", longitude: 118.2757, latitude: 33.9630)
        ],
        "浙江": [
            City(province: "浙江", name: "杭州市", longitude: 120.1551, latitude: 30.2741),
            City(province: "浙江", name: "宁波市", longitude: 121.5440, latitude: 29.8683),
            City(province: "浙江", name: "温州市", longitude: 120.6994, latitude: 28.0006),
            City(province: "浙江", name: "嘉兴市", longitude: 120.7555, latitude: 30.7469),
            City(province: "浙江", name: "湖州市", longitude: 120.0873, latitude: 30.8943),
            City(province: "浙江", name: "绍兴市", longitude: 120.5820, latitude: 29.9971),
            City(province: "浙江", name: "金华市", longitude: 119.6477, latitude: 29.0789),
            City(province: "浙江", name: "衢州市", longitude: 118.8735, latitude: 28.9417),
            City(province: "浙江", name: "舟山市", longitude: 122.2069, latitude: 29.9853),
            City(province: "浙江", name: "台州市", longitude: 121.4207, latitude: 28.6564),
            City(province: "浙江", name: "丽水市", longitude: 119.9229, latitude: 28.4517)
        ],
        "安徽": [
            City(province: "安徽", name: "合肥市", longitude: 117.2272, latitude: 31.8206),
            City(province: "安徽", name: "芜湖市", longitude: 118.4330, latitude: 31.3520),
            City(province: "安徽", name: "蚌埠市", longitude: 117.3889, latitude: 32.9161),
            City(province: "安徽", name: "淮南市", longitude: 117.0182, latitude: 32.6475),
            City(province: "安徽", name: "马鞍山市", longitude: 118.5076, latitude: 31.6895),
            City(province: "安徽", name: "淮北市", longitude: 116.7983, latitude: 33.9717),
            City(province: "安徽", name: "铜陵市", longitude: 117.8122, latitude: 30.9456),
            City(province: "安徽", name: "安庆市", longitude: 117.0538, latitude: 30.5255),
            City(province: "安徽", name: "黄山市", longitude: 118.3378, latitude: 29.7146),
            City(province: "安徽", name: "滁州市", longitude: 118.3162, latitude: 32.3016),
            City(province: "安徽", name: "阜阳市", longitude: 115.8197, latitude: 32.8970),
            City(province: "安徽", name: "宿州市", longitude: 116.9640, latitude: 33.6333),
            City(province: "安徽", name: "六安市", longitude: 116.5078, latitude: 31.7529),
            City(province: "安徽", name: "亳州市", longitude: 115.7788, latitude: 33.8712),
            City(province: "安徽", name: "池州市", longitude: 117.4894, latitude: 30.6643),
            City(province: "安徽", name: "宣城市", longitude: 118.7587, latitude: 30.9407)
        ],
        "福建": [
            City(province: "福建", name: "福州市", longitude: 119.2965, latitude: 26.0745),
            City(province: "福建", name: "厦门市", longitude: 118.0894, latitude: 24.4798),
            City(province: "福建", name: "莆田市", longitude: 119.0077, latitude: 25.4540),
            City(province: "福建", name: "三明市", longitude: 117.6389, latitude: 26.2654),
            City(province: "福建", name: "泉州市", longitude: 118.6754, latitude: 24.8740),
            City(province: "福建", name: "漳州市", longitude: 117.6472, latitude: 24.5107),
            City(province: "福建", name: "南平市", longitude: 118.1771, latitude: 26.6419),
            City(province: "福建", name: "龙岩市", longitude: 117.0172, latitude: 25.0916),
            City(province: "福建", name: "宁德市", longitude: 119.5479, latitude: 26.6590)
        ],
        "江西": [
            City(province: "江西", name: "南昌市", longitude: 115.8581, latitude: 28.6832),
            City(province: "江西", name: "景德镇市", longitude: 117.1784, latitude: 29.2686),
            City(province: "江西", name: "萍乡市", longitude: 113.8528, latitude: 27.6229),
            City(province: "江西", name: "九江市", longitude: 116.0018, latitude: 29.7051),
            City(province: "江西", name: "新余市", longitude: 114.9167, latitude: 27.8174),
            City(province: "江西", name: "鹰潭市", longitude: 117.0695, latitude: 28.2386),
            City(province: "江西", name: "赣州市", longitude: 114.9403, latitude: 25.8311),
            City(province: "江西", name: "吉安市", longitude: 114.9926, latitude: 27.1117),
            City(province: "江西", name: "宜春市", longitude: 114.4163, latitude: 27.8153),
            City(province: "江西", name: "抚州市", longitude: 116.3581, latitude: 27.9487),
            City(province: "江西", name: "上饶市", longitude: 117.9434, latitude: 28.4544)
        ],
        "山东": [
            City(province: "山东", name: "济南市", longitude: 117.1205, latitude: 36.6519),
            City(province: "山东", name: "青岛市", longitude: 120.3826, latitude: 36.0671),
            City(province: "山东", name: "淄博市", longitude: 118.0548, latitude: 36.8134),
            City(province: "山东", name: "枣庄市", longitude: 117.3231, latitude: 34.8108),
            City(province: "山东", name: "东营市", longitude: 118.6748, latitude: 37.4343),
            City(province: "山东", name: "烟台市", longitude: 121.4478, latitude: 37.4638),
            City(province: "山东", name: "潍坊市", longitude: 119.1617, latitude: 36.7067),
            City(province: "山东", name: "济宁市", longitude: 116.5873, latitude: 35.4150),
            City(province: "山东", name: "泰安市", longitude: 117.0888, latitude: 36.2006),
            City(province: "山东", name: "威海市", longitude: 122.1206, latitude: 37.5091),
            City(province: "山东", name: "日照市", longitude: 119.5269, latitude: 35.4164),
            City(province: "山东", name: "临沂市", longitude: 118.3564, latitude: 35.1045),
            City(province: "山东", name: "德州市", longitude: 116.3594, latitude: 37.4355),
            City(province: "山东", name: "聊城市", longitude: 115.9855, latitude: 36.4567),
            City(province: "山东", name: "滨州市", longitude: 117.9708, latitude: 37.3836),
            City(province: "山东", name: "菏泽市", longitude: 115.4808, latitude: 35.2333)
        ],
        "河南": [
            City(province: "河南", name: "郑州市", longitude: 113.6254, latitude: 34.7466),
            City(province: "河南", name: "开封市", longitude: 114.3071, latitude: 34.7973),
            City(province: "河南", name: "洛阳市", longitude: 112.4540, latitude: 34.6197),
            City(province: "河南", name: "平顶山市", longitude: 113.1926, latitude: 33.7667),
            City(province: "河南", name: "安阳市", longitude: 114.3929, latitude: 36.0974),
            City(province: "河南", name: "鹤壁市", longitude: 114.2974, latitude: 35.7480),
            City(province: "河南", name: "新乡市", longitude: 113.9269, latitude: 35.3026),
            City(province: "河南", name: "焦作市", longitude: 113.2420, latitude: 35.2159),
            City(province: "河南", name: "濮阳市", longitude: 115.0293, latitude: 35.7617),
            City(province: "河南", name: "许昌市", longitude: 113.8526, latitude: 34.0356),
            City(province: "河南", name: "漯河市", longitude: 114.0166, latitude: 33.5819),
            City(province: "河南", name: "三门峡市", longitude: 111.1945, latitude: 34.7730),
            City(province: "河南", name: "南阳市", longitude: 112.5285, latitude: 32.9909),
            City(province: "河南", name: "商丘市", longitude: 115.6568, latitude: 34.4143),
            City(province: "河南", name: "信阳市", longitude: 114.0913, latitude: 32.1470),
            City(province: "河南", name: "周口市", longitude: 114.6496, latitude: 33.6250),
            City(province: "河南", name: "驻马店市", longitude: 114.0221, latitude: 32.9803)
        ],
        "湖北": [
            City(province: "湖北", name: "武汉市", longitude: 114.3055, latitude: 30.5931),
            City(province: "湖北", name: "黄石市", longitude: 115.0385, latitude: 30.1993),
            City(province: "湖北", name: "十堰市", longitude: 110.7989, latitude: 32.6292),
            City(province: "湖北", name: "宜昌市", longitude: 111.2868, latitude: 30.6919),
            City(province: "湖北", name: "襄阳市", longitude: 112.1226, latitude: 32.0091),
            City(province: "湖北", name: "鄂州市", longitude: 114.8949, latitude: 30.3917),
            City(province: "湖北", name: "荆门市", longitude: 112.1991, latitude: 31.0354),
            City(province: "湖北", name: "孝感市", longitude: 113.9169, latitude: 30.9269),
            City(province: "湖北", name: "荆州市", longitude: 112.2407, latitude: 30.3354),
            City(province: "湖北", name: "黄冈市", longitude: 114.8726, latitude: 30.4536),
            City(province: "湖北", name: "咸宁市", longitude: 114.3222, latitude: 29.8410),
            City(province: "湖北", name: "随州市", longitude: 113.3826, latitude: 31.6906),
            City(province: "湖北", name: "恩施土家族苗族自治州", longitude: 109.4889, latitude: 30.2729)
        ],
        "湖南": [
            City(province: "湖南", name: "长沙市", longitude: 112.9388, latitude: 28.2282),
            City(province: "湖南", name: "株洲市", longitude: 113.1336, latitude: 27.8274),
            City(province: "湖南", name: "湘潭市", longitude: 112.9443, latitude: 27.8297),
            City(province: "湖南", name: "衡阳市", longitude: 112.5717, latitude: 26.8933),
            City(province: "湖南", name: "邵阳市", longitude: 111.4677, latitude: 27.2389),
            City(province: "湖南", name: "岳阳市", longitude: 113.1289, latitude: 29.3570),
            City(province: "湖南", name: "常德市", longitude: 111.6981, latitude: 29.0319),
            City(province: "湖南", name: "张家界市", longitude: 110.4790, latitude: 29.1274),
            City(province: "湖南", name: "益阳市", longitude: 112.3550, latitude: 28.5538),
            City(province: "湖南", name: "郴州市", longitude: 113.0144, latitude: 25.7705),
            City(province: "湖南", name: "永州市", longitude: 111.6133, latitude: 26.4206),
            City(province: "湖南", name: "怀化市", longitude: 109.9787, latitude: 27.5500),
            City(province: "湖南", name: "娄底市", longitude: 111.9937, latitude: 27.6981),
            City(province: "湖南", name: "湘西土家族苗族自治州", longitude: 109.7397, latitude: 28.3114)
        ],
        "广东": [
            City(province: "广东", name: "广州市", longitude: 113.2644, latitude: 23.1291),
            City(province: "广东", name: "韶关市", longitude: 113.5972, latitude: 24.8101),
            City(province: "广东", name: "深圳市", longitude: 114.0579, latitude: 22.5431),
            City(province: "广东", name: "珠海市", longitude: 113.5767, latitude: 22.2707),
            City(province: "广东", name: "汕头市", longitude: 116.6816, latitude: 23.3540),
            City(province: "广东", name: "佛山市", longitude: 113.1220, latitude: 23.0217),
            City(province: "广东", name: "江门市", longitude: 113.0814, latitude: 22.5789),
            City(province: "广东", name: "湛江市", longitude: 110.3577, latitude: 21.2707),
            City(province: "广东", name: "茂名市", longitude: 110.9255, latitude: 21.6631),
            City(province: "广东", name: "肇庆市", longitude: 112.4650, latitude: 23.0479),
            City(province: "广东", name: "惠州市", longitude: 114.4152, latitude: 23.1115),
            City(province: "广东", name: "梅州市", longitude: 116.1224, latitude: 24.2888),
            City(province: "广东", name: "汕尾市", longitude: 115.3750, latitude: 22.7787),
            City(province: "广东", name: "河源市", longitude: 114.7008, latitude: 23.7433),
            City(province: "广东", name: "阳江市", longitude: 111.9827, latitude: 21.8575),
            City(province: "广东", name: "清远市", longitude: 113.0564, latitude: 23.6817),
            City(province: "广东", name: "东莞市", longitude: 113.7518, latitude: 23.0206),
            City(province: "广东", name: "中山市", longitude: 113.3926, latitude: 22.5171),
            City(province: "广东", name: "潮州市", longitude: 116.6229, latitude: 23.6567),
            City(province: "广东", name: "揭阳市", longitude: 116.3727, latitude: 23.5498),
            City(province: "广东", name: "云浮市", longitude: 112.0444, latitude: 22.9151)
        ],
        "广西": [
            City(province: "广西", name: "南宁市", longitude: 108.3669, latitude: 22.8172),
            City(province: "广西", name: "柳州市", longitude: 109.4281, latitude: 24.3265),
            City(province: "广西", name: "桂林市", longitude: 110.2901, latitude: 25.2736),
            City(province: "广西", name: "梧州市", longitude: 111.2797, latitude: 23.4769),
            City(province: "广西", name: "北海市", longitude: 109.1195, latitude: 21.4813),
            City(province: "广西", name: "防城港市", longitude: 108.3548, latitude: 21.6867),
            City(province: "广西", name: "钦州市", longitude: 108.6543, latitude: 21.9798),
            City(province: "广西", name: "贵港市", longitude: 109.6029, latitude: 23.1115),
            City(province: "广西", name: "玉林市", longitude: 110.1811, latitude: 22.6542),
            City(province: "广西", name: "百色市", longitude: 106.6183, latitude: 23.9024),
            City(province: "广西", name: "贺州市", longitude: 111.5669, latitude: 24.4038),
            City(province: "广西", name: "河池市", longitude: 108.0855, latitude: 24.6926),
            City(province: "广西", name: "来宾市", longitude: 109.2216, latitude: 23.7509),
            City(province: "广西", name: "崇左市", longitude: 107.3645, latitude: 22.3768)
        ],
        "海南": [
            City(province: "海南", name: "海口市", longitude: 110.3312, latitude: 20.0311),
            City(province: "海南", name: "三亚市", longitude: 109.5122, latitude: 18.2528),
            City(province: "海南", name: "三沙市", longitude: 112.3387, latitude: 16.8319),
            City(province: "海南", name: "儋州市", longitude: 109.5765, latitude: 19.5175)
        ],
        "四川": [
            City(province: "四川", name: "成都市", longitude: 104.0665, latitude: 30.5723),
            City(province: "四川", name: "自贡市", longitude: 104.7789, latitude: 29.3387),
            City(province: "四川", name: "攀枝花市", longitude: 101.7184, latitude: 26.5804),
            City(province: "四川", name: "泸州市", longitude: 105.4432, latitude: 28.8719),
            City(province: "四川", name: "德阳市", longitude: 104.3979, latitude: 31.1269),
            City(province: "四川", name: "绵阳市", longitude: 104.6794, latitude: 31.4671),
            City(province: "四川", name: "广元市", longitude: 105.8296, latitude: 32.4353),
            City(province: "四川", name: "遂宁市", longitude: 105.5714, latitude: 30.5327),
            City(province: "四川", name: "内江市", longitude: 105.0582, latitude: 29.5801),
            City(province: "四川", name: "乐山市", longitude: 103.7651, latitude: 29.5524),
            City(province: "四川", name: "南充市", longitude: 106.0826, latitude: 30.7993),
            City(province: "四川", name: "眉山市", longitude: 103.8485, latitude: 30.0751),
            City(province: "四川", name: "宜宾市", longitude: 104.6431, latitude: 28.7516),
            City(province: "四川", name: "广安市", longitude: 106.6333, latitude: 30.4564),
            City(province: "四川", name: "达州市", longitude: 107.4682, latitude: 31.2094),
            City(province: "四川", name: "雅安市", longitude: 103.0413, latitude: 29.9800),
            City(province: "四川", name: "巴中市", longitude: 106.7537, latitude: 31.8586),
            City(province: "四川", name: "资阳市", longitude: 104.6419, latitude: 30.1222),
            City(province: "四川", name: "阿坝藏族羌族自治州", longitude: 102.2211, latitude: 31.8998),
            City(province: "四川", name: "甘孜藏族自治州", longitude: 101.9638, latitude: 30.0503),
            City(province: "四川", name: "凉山彝族自治州", longitude: 102.2587, latitude: 27.8868)
        ],
        "贵州": [
            City(province: "贵州", name: "贵阳市", longitude: 106.7135, latitude: 26.5783),
            City(province: "贵州", name: "六盘水市", longitude: 104.8305, latitude: 26.5846),
            City(province: "贵州", name: "遵义市", longitude: 106.9272, latitude: 27.7059),
            City(province: "贵州", name: "安顺市", longitude: 105.9462, latitude: 26.2455),
            City(province: "贵州", name: "毕节市", longitude: 105.2862, latitude: 27.2842),
            City(province: "贵州", name: "铜仁市", longitude: 109.1896, latitude: 27.7183),
            City(province: "贵州", name: "黔西南布依族苗族自治州", longitude: 104.9003, latitude: 25.0881),
            City(province: "贵州", name: "黔东南苗族侗族自治州", longitude: 107.9774, latitude: 26.5839),
            City(province: "贵州", name: "黔南布依族苗族自治州", longitude: 107.5173, latitude: 26.2583)
        ],
        "云南": [
            City(province: "云南", name: "昆明市", longitude: 102.8329, latitude: 24.8801),
            City(province: "云南", name: "曲靖市", longitude: 103.7976, latitude: 25.4899),
            City(province: "云南", name: "玉溪市", longitude: 102.5437, latitude: 24.3505),
            City(province: "云南", name: "保山市", longitude: 99.1616, latitude: 25.1118),
            City(province: "云南", name: "昭通市", longitude: 103.7170, latitude: 27.3383),
            City(province: "云南", name: "丽江市", longitude: 100.2270, latitude: 26.8721),
            City(province: "云南", name: "普洱市", longitude: 100.9664, latitude: 22.8257),
            City(province: "云南", name: "临沧市", longitude: 100.0886, latitude: 23.8868),
            City(province: "云南", name: "楚雄彝族自治州", longitude: 101.5281, latitude: 25.0459),
            City(province: "云南", name: "红河哈尼族彝族自治州", longitude: 103.3744, latitude: 23.3631),
            City(province: "云南", name: "文山壮族苗族自治州", longitude: 104.2167, latitude: 23.3695),
            City(province: "云南", name: "西双版纳傣族自治州", longitude: 100.7979, latitude: 22.0017),
            City(province: "云南", name: "大理白族自治州", longitude: 100.2677, latitude: 25.6064),
            City(province: "云南", name: "德宏傣族景颇族自治州", longitude: 98.5784, latitude: 24.4330),
            City(province: "云南", name: "怒江傈僳族自治州", longitude: 98.8567, latitude: 25.8509),
            City(province: "云南", name: "迪庆藏族自治州", longitude: 99.7065, latitude: 27.8269)
        ],
        "西藏": [
            City(province: "西藏", name: "拉萨市", longitude: 91.1145, latitude: 29.6446),
            City(province: "西藏", name: "日喀则市", longitude: 88.8851, latitude: 29.2690),
            City(province: "西藏", name: "昌都市", longitude: 97.1785, latitude: 31.1369),
            City(province: "西藏", name: "林芝市", longitude: 94.3617, latitude: 29.6548),
            City(province: "西藏", name: "山南市", longitude: 91.7730, latitude: 29.2369),
            City(province: "西藏", name: "那曲市", longitude: 92.0535, latitude: 31.4806),
            City(province: "西藏", name: "阿里地区", longitude: 80.1056, latitude: 32.5011)
        ],
        "陕西": [
            City(province: "陕西", name: "西安市", longitude: 108.9398, latitude: 34.3416),
            City(province: "陕西", name: "铜川市", longitude: 108.9451, latitude: 34.8969),
            City(province: "陕西", name: "宝鸡市", longitude: 107.2372, latitude: 34.3609),
            City(province: "陕西", name: "咸阳市", longitude: 108.7093, latitude: 34.3292),
            City(province: "陕西", name: "渭南市", longitude: 109.5097, latitude: 34.4995),
            City(province: "陕西", name: "延安市", longitude: 109.4897, latitude: 36.5853),
            City(province: "陕西", name: "汉中市", longitude: 107.0281, latitude: 33.0677),
            City(province: "陕西", name: "榆林市", longitude: 109.7341, latitude: 38.2853),
            City(province: "陕西", name: "安康市", longitude: 109.0293, latitude: 32.6851),
            City(province: "陕西", name: "商洛市", longitude: 109.9402, latitude: 33.8682)
        ],
        "甘肃": [
            City(province: "甘肃", name: "兰州市", longitude: 103.8343, latitude: 36.0611),
            City(province: "甘肃", name: "嘉峪关市", longitude: 98.2772, latitude: 39.7721),
            City(province: "甘肃", name: "金昌市", longitude: 102.1877, latitude: 38.5140),
            City(province: "甘肃", name: "白银市", longitude: 104.1390, latitude: 36.5448),
            City(province: "甘肃", name: "天水市", longitude: 105.7249, latitude: 34.5808),
            City(province: "甘肃", name: "武威市", longitude: 102.6380, latitude: 37.9289),
            City(province: "甘肃", name: "张掖市", longitude: 100.4510, latitude: 38.9251),
            City(province: "甘肃", name: "平凉市", longitude: 106.6650, latitude: 35.5428),
            City(province: "甘肃", name: "酒泉市", longitude: 98.4941, latitude: 39.7332),
            City(province: "甘肃", name: "庆阳市", longitude: 107.6433, latitude: 35.7095),
            City(province: "甘肃", name: "定西市", longitude: 104.6260, latitude: 35.5806),
            City(province: "甘肃", name: "陇南市", longitude: 104.9216, latitude: 33.4006),
            City(province: "甘肃", name: "临夏回族自治州", longitude: 103.2115, latitude: 35.5994),
            City(province: "甘肃", name: "甘南藏族自治州", longitude: 102.9111, latitude: 34.9834)
        ],
        "青海": [
            City(province: "青海", name: "西宁市", longitude: 101.7782, latitude: 36.6171),
            City(province: "青海", name: "海东市", longitude: 102.1041, latitude: 36.5029),
            City(province: "青海", name: "海北藏族自治州", longitude: 100.9010, latitude: 36.9544),
            City(province: "青海", name: "黄南藏族自治州", longitude: 102.0076, latitude: 35.5177),
            City(province: "青海", name: "海南藏族自治州", longitude: 100.6233, latitude: 36.2804),
            City(province: "青海", name: "果洛藏族自治州", longitude: 100.2426, latitude: 34.4717),
            City(province: "青海", name: "玉树藏族自治州", longitude: 97.0086, latitude: 33.0041),
            City(province: "青海", name: "海西蒙古族藏族自治州", longitude: 97.3708, latitude: 37.3743)
        ],
        "宁夏": [
            City(province: "宁夏", name: "银川市", longitude: 106.2586, latitude: 38.4680),
            City(province: "宁夏", name: "石嘴山市", longitude: 106.3839, latitude: 39.0133),
            City(province: "宁夏", name: "吴忠市", longitude: 106.1987, latitude: 37.9862),
            City(province: "宁夏", name: "固原市", longitude: 106.2428, latitude: 36.0159),
            City(province: "宁夏", name: "中卫市", longitude: 105.1897, latitude: 37.4993)
        ],
        "新疆": [
            City(province: "新疆", name: "乌鲁木齐市", longitude: 87.6168, latitude: 43.8256),
            City(province: "新疆", name: "克拉玛依市", longitude: 84.8891, latitude: 45.5794),
            City(province: "新疆", name: "吐鲁番市", longitude: 89.1815, latitude: 42.9513),
            City(province: "新疆", name: "哈密市", longitude: 93.5151, latitude: 42.8185),
            City(province: "新疆", name: "昌吉回族自治州", longitude: 87.3040, latitude: 44.0070),
            City(province: "新疆", name: "博尔塔拉蒙古自治州", longitude: 82.0670, latitude: 44.9058),
            City(province: "新疆", name: "巴音郭楞蒙古自治州", longitude: 86.1459, latitude: 41.7686),
            City(province: "新疆", name: "阿克苏地区", longitude: 80.2651, latitude: 41.1717),
            City(province: "新疆", name: "克孜勒苏柯尔克孜自治州", longitude: 76.1679, latitude: 39.7149),
            City(province: "新疆", name: "喀什地区", longitude: 75.9893, latitude: 39.4677),
            City(province: "新疆", name: "和田地区", longitude: 79.9226, latitude: 37.1107),
            City(province: "新疆", name: "伊犁哈萨克自治州", longitude: 81.3179, latitude: 43.9171),
            City(province: "新疆", name: "塔城地区", longitude: 82.9856, latitude: 46.7456),
            City(province: "新疆", name: "阿勒泰地区", longitude: 88.1396, latitude: 47.8484)
        ],
        // 臺灣 - 完整城市列表
        "臺灣": [
            // 六都
            City(province: "臺灣", name: "臺北市", longitude: 121.5654, latitude: 25.0330),
            City(province: "臺灣", name: "新北市", longitude: 121.4628, latitude: 25.0170),
            City(province: "臺灣", name: "桃園市", longitude: 121.3009, latitude: 24.9937),
            City(province: "臺灣", name: "臺中市", longitude: 120.6736, latitude: 24.1477),
            City(province: "臺灣", name: "臺南市", longitude: 120.2269, latitude: 22.9998),
            City(province: "臺灣", name: "高雄市", longitude: 120.3014, latitude: 22.6273),
            // 其他縣市
            City(province: "臺灣", name: "基隆市", longitude: 121.7419, latitude: 25.1276),
            City(province: "臺灣", name: "新竹市", longitude: 120.9647, latitude: 24.8066),
            City(province: "臺灣", name: "新竹縣", longitude: 121.0177, latitude: 24.8387),
            City(province: "臺灣", name: "苗栗縣", longitude: 120.8214, latitude: 24.5602),
            City(province: "臺灣", name: "彰化縣", longitude: 120.5161, latitude: 24.0518),
            City(province: "臺灣", name: "南投縣", longitude: 120.9876, latitude: 23.8313),
            City(province: "臺灣", name: "雲林縣", longitude: 120.5312, latitude: 23.7092),
            City(province: "臺灣", name: "嘉義市", longitude: 120.4491, latitude: 23.4801),
            City(province: "臺灣", name: "嘉義縣", longitude: 120.5740, latitude: 23.4589),
            City(province: "臺灣", name: "屏東縣", longitude: 120.4879, latitude: 22.5519),
            City(province: "臺灣", name: "宜蘭縣", longitude: 121.7195, latitude: 24.6915),
            City(province: "臺灣", name: "花蓮縣", longitude: 121.6014, latitude: 23.9871),
            City(province: "臺灣", name: "臺東縣", longitude: 121.1136, latitude: 22.7583),
            City(province: "臺灣", name: "澎湖縣", longitude: 119.5793, latitude: 23.5711),
            City(province: "臺灣", name: "金門縣", longitude: 118.3186, latitude: 24.4493),
            City(province: "臺灣", name: "連江縣", longitude: 119.9500, latitude: 26.1600)
        ],
        // 香港 - 十八區
        "香港": [
            City(province: "香港", name: "中西區", longitude: 114.1543, latitude: 22.2860),
            City(province: "香港", name: "灣仔區", longitude: 114.1829, latitude: 22.2769),
            City(province: "香港", name: "東區", longitude: 114.2260, latitude: 22.2840),
            City(province: "香港", name: "南區", longitude: 114.1600, latitude: 22.2420),
            City(province: "香港", name: "油尖旺區", longitude: 114.1694, latitude: 22.3119),
            City(province: "香港", name: "深水埗區", longitude: 114.1632, latitude: 22.3281),
            City(province: "香港", name: "九龍城區", longitude: 114.1927, latitude: 22.3282),
            City(province: "香港", name: "黃大仙區", longitude: 114.2046, latitude: 22.3419),
            City(province: "香港", name: "觀塘區", longitude: 114.2310, latitude: 22.3124),
            City(province: "香港", name: "葵青區", longitude: 114.1390, latitude: 22.3540),
            City(province: "香港", name: "荃灣區", longitude: 114.1141, latitude: 22.3684),
            City(province: "香港", name: "屯門區", longitude: 113.9770, latitude: 22.3910),
            City(province: "香港", name: "元朗區", longitude: 114.0324, latitude: 22.4431),
            City(province: "香港", name: "北區", longitude: 114.1489, latitude: 22.4940),
            City(province: "香港", name: "大埔區", longitude: 114.1713, latitude: 22.4513),
            City(province: "香港", name: "沙田區", longitude: 114.1952, latitude: 22.3880),
            City(province: "香港", name: "西貢區", longitude: 114.2740, latitude: 22.3850),
            City(province: "香港", name: "離島區", longitude: 113.9446, latitude: 22.2619)
        ],
        // 澳門
        "澳門": [
            City(province: "澳門", name: "澳門半島", longitude: 113.5439, latitude: 22.1987),
            City(province: "澳門", name: "氹仔", longitude: 113.5577, latitude: 22.1560),
            City(province: "澳門", name: "路環", longitude: 113.5649, latitude: 22.1263),
            City(province: "澳門", name: "路氹城", longitude: 113.5613, latitude: 22.1410)
        ],
        // 新加坡
        "新加坡": [
            City(province: "新加坡", name: "Central Area", longitude: 103.8198, latitude: 1.3521),
            City(province: "新加坡", name: "Orchard", longitude: 103.8322, latitude: 1.3048),
            City(province: "新加坡", name: "Marina Bay", longitude: 103.8608, latitude: 1.2819),
            City(province: "新加坡", name: "Chinatown", longitude: 103.8440, latitude: 1.2836),
            City(province: "新加坡", name: "Little India", longitude: 103.8500, latitude: 1.3066),
            City(province: "新加坡", name: "Bugis", longitude: 103.8555, latitude: 1.2995),
            City(province: "新加坡", name: "Jurong", longitude: 103.7415, latitude: 1.3329),
            City(province: "新加坡", name: "Tampines", longitude: 103.9456, latitude: 1.3496),
            City(province: "新加坡", name: "Woodlands", longitude: 103.7863, latitude: 1.4382),
            City(province: "新加坡", name: "Punggol", longitude: 103.9021, latitude: 1.4023),
            City(province: "新加坡", name: "Sengkang", longitude: 103.8914, latitude: 1.3868),
            City(province: "新加坡", name: "Sembawang", longitude: 103.8202, latitude: 1.4491),
            City(province: "新加坡", name: "Yishun", longitude: 103.8355, latitude: 1.4180),
            City(province: "新加坡", name: "Bishan", longitude: 103.8487, latitude: 1.3530),
            City(province: "新加坡", name: "Ang Mo Kio", longitude: 103.8454, latitude: 1.3691),
            City(province: "新加坡", name: "Toa Payoh", longitude: 103.8489, latitude: 1.3343),
            City(province: "新加坡", name: "Clementi", longitude: 103.7649, latitude: 1.3151),
            City(province: "新加坡", name: "West Coast", longitude: 103.7558, latitude: 1.2948),
            City(province: "新加坡", name: "East Coast", longitude: 103.9287, latitude: 1.3064),
            City(province: "新加坡", name: "Bedok", longitude: 103.9322, latitude: 1.3250)
        ],
        // 马来西亚
        "马来西亚": [
            // Federal Territories
            City(province: "马来西亚", name: "Kuala Lumpur", longitude: 101.6869, latitude: 3.1390),
            City(province: "马来西亚", name: "Putrajaya", longitude: 101.6942, latitude: 2.9264),
            City(province: "马来西亚", name: "Labuan", longitude: 115.2308, latitude: 5.2831),
            // Selangor
            City(province: "马来西亚", name: "Shah Alam", longitude: 101.5326, latitude: 3.0733),
            City(province: "马来西亚", name: "Petaling Jaya", longitude: 101.6074, latitude: 3.1067),
            City(province: "马来西亚", name: "Subang Jaya", longitude: 101.5858, latitude: 3.0492),
            City(province: "马来西亚", name: "Klang", longitude: 101.4453, latitude: 3.0449),
            City(province: "马来西亚", name: "Puchong", longitude: 101.6179, latitude: 3.0264),
            // Penang
            City(province: "马来西亚", name: "George Town", longitude: 100.3292, latitude: 5.4164),
            City(province: "马来西亚", name: "Bukit Mertajam", longitude: 100.4417, latitude: 5.3678),
            City(province: "马来西亚", name: "Butterworth", longitude: 100.3957, latitude: 5.3988),
            // Johor
            City(province: "马来西亚", name: "Johor Bahru", longitude: 103.7578, latitude: 1.4927),
            City(province: "马来西亚", name: "Kulai", longitude: 103.6082, latitude: 1.6503),
            City(province: "马来西亚", name: "Batu Pahat", longitude: 103.0564, latitude: 1.8548),
            City(province: "马来西亚", name: "Muar", longitude: 102.4289, latitude: 1.8640),
            City(province: "马来西亚", name: "Kluang", longitude: 103.4232, latitude: 2.0253),
            // Perak
            City(province: "马来西亚", name: "Ipoh", longitude: 101.0901, latitude: 4.5975),
            City(province: "马来西亚", name: "Taiping", longitude: 100.7408, latitude: 4.8508),
            // Kedah
            City(province: "马来西亚", name: "Alor Setar", longitude: 100.3681, latitude: 6.1254),
            City(province: "马来西亚", name: "Sungai Petani", longitude: 100.5067, latitude: 5.6416),
            // Negeri Sembilan
            City(province: "马来西亚", name: "Seremban", longitude: 101.9424, latitude: 2.7258),
            // Malacca
            City(province: "马来西亚", name: "Malacca City", longitude: 102.2501, latitude: 2.1896),
            // Kelantan
            City(province: "马来西亚", name: "Kota Bharu", longitude: 102.2389, latitude: 6.1254),
            // Terengganu
            City(province: "马来西亚", name: "Kuala Terengganu", longitude: 103.1324, latitude: 5.3117),
            // Pahang
            City(province: "马来西亚", name: "Kuantan", longitude: 103.4324, latitude: 3.8126),
            City(province: "马来西亚", name: "Genting Highlands", longitude: 101.7933, latitude: 3.4224),
            // Perlis
            City(province: "马来西亚", name: "Kangar", longitude: 100.1937, latitude: 6.4323),
            // Sabah
            City(province: "马来西亚", name: "Kota Kinabalu", longitude: 116.0735, latitude: 5.9804),
            City(province: "马来西亚", name: "Sandakan", longitude: 118.1170, latitude: 5.8402),
            City(province: "马来西亚", name: "Tawau", longitude: 117.8912, latitude: 4.2445),
            // Sarawak
            City(province: "马来西亚", name: "Kuching", longitude: 110.3441, latitude: 1.5497),
            City(province: "马来西亚", name: "Sibu", longitude: 111.8241, latitude: 2.2917),
            City(province: "马来西亚", name: "Miri", longitude: 113.9870, latitude: 4.3995),
            City(province: "马来西亚", name: "Bintulu", longitude: 113.0391, latitude: 3.1727)
        ]
    ]
}
