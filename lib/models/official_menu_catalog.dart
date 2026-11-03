// TAP_JAYA_FINAL_2026: katalog resmi, bahasa deskripsi Indonesia.
// Data resmi: TKJ Begawan West Menu (Digital), © August 2026.
// Harga disalin dari PDF perusahaan. Opsi kombinasi tambahan hanya rancangan UI/UX TAP JAYA.
class OfficialAddon {
  final String name;
  final int price;
  const OfficialAddon(this.name, this.price);
}

class OfficialVariant {
  final String name;
  final int price;
  const OfficialVariant(this.name, this.price);
  String get label => name;
}

class OfficialProduct {
  final String id, name, category, description;
  final String? image;
  final List<OfficialVariant> variants;
  const OfficialProduct(
    this.id,
    this.name,
    this.category,
    this.description,
    this.image,
    this.variants,
  );
  String? get imagePath => image;
  bool get priceVerified => true;
  int get lowestPrice =>
      variants.map((e) => e.price).reduce((a, b) => a < b ? a : b);
}

class OfficialMenuCatalog {
  OfficialMenuCatalog._();
  // Kategori tetap dalam bahasa Inggris, sesuai menu TKJ Begawan West.
  static const categories = <String>[
    'Semua',
    'Signature',
    'Black Series',
    'Milk Based Coffee',
    'Manual',
    'Milk Based',
    'Tea',
    'Chocolate',
    'Main Course',
    'Chicken Wings',
    'Pizza Porter',
    'Snack',
  ];
  static const addOnPrices = <String, int>{
    "Mineral Water": 7273,
    "Extra Shot": 8182,
    "Gula Aren": 3636,
    "Whip Cream": 4545,
    "Madu": 6364,
    "Nasi Uduk": 5455,
    "Sunny Side Up Egg": 5455,
    "Chili Sauce": 3636,
    "Bangkok Sauce": 4545,
    "Chili Oil": 4545,
    "BBQ Sauce": 6364,
    "Coffee Sauce": 6364,
  };
  // Produk dan harga berdasarkan PDF perusahaan (Add On hanya untuk detail).
  static const menus = <OfficialProduct>[
    OfficialProduct(
      "berjaya_di_bali",
      "Berjaya di Bali",
      "Signature",
      "Kopi susu khas Toko Kopi Jaya yang memadukan espresso dengan susu bertekstur lembut dan rasa gurih yang kaya. Cocok untuk penyuka kopi susu yang creamy.",
      "assets/images/menu_begawan/berjaya_di_bali.jpg",
      <OfficialVariant>[
        OfficialVariant("Regular", 24545),
        OfficialVariant("Large", 30000),
      ],
    ),
    OfficialProduct(
      "kopi_susu_mantap_jaya",
      "Kopi Susu Mantap Jaya",
      "Signature",
      "Kopi susu bercita rasa kuat dengan dua takaran espresso yang pekat. Racikan kopi susu khas Toko Kopi Jaya.",
      "assets/images/menu_begawan/kopi_susu_mantap_jaya.jpg",
      <OfficialVariant>[
        OfficialVariant("Regular", 16364),
        OfficialVariant("Medium", 21819),
        OfficialVariant("Large", 24545),
      ],
    ),
    OfficialProduct(
      "kopi_susu_jaya",
      "Kopi Susu Jaya",
      "Signature",
      "Kopi susu lembut dan kental dengan perpaduan espresso yang seimbang. Racikan kopi susu khas Toko Kopi Jaya.",
      "assets/images/menu_begawan/kopi_susu_jaya.jpg",
      <OfficialVariant>[
        OfficialVariant("Regular", 15455),
        OfficialVariant("Medium", 20000),
        OfficialVariant("Large", 23636),
      ],
    ),
    OfficialProduct(
      "americano",
      "Americano",
      "Black Series",
      "Kopi hitam berbasis espresso dengan karakter ringan dan rasa akhir yang halus, cocok untuk menikmati cita rasa kopi tanpa susu.",
      "assets/images/menu_begawan/americano.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 15455)],
    ),
    OfficialProduct(
      "lemongrass_americano",
      "Lemongrass Americano",
      "Black Series",
      "Kopi hitam yang menyegarkan dengan sentuhan aroma serai manis, menghasilkan perpaduan rasa kopi dan rempah yang unik.",
      "assets/images/menu_begawan/lemongrass_americano.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 18182)],
    ),
    OfficialProduct(
      "watermelon_americano",
      "Watermelon Americano",
      "Black Series",
      "Kopi hitam dengan rasa manis dan kesegaran semangka, memberikan karakter buah yang berbeda pada racikan espresso.",
      "assets/images/menu_begawan/watermelon_americano.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 28182)],
    ),
    OfficialProduct(
      "aromatic_americano",
      "Aromatic Americano",
      "Black Series",
      "Kopi hitam bertekstur ringan dengan aroma bunga osmanthus yang lembut, memberikan sensasi harum yang khas.",
      "assets/images/menu_begawan/aromatic_americano.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 22727)],
    ),
    OfficialProduct(
      "coconut_americano",
      "Coconut Americano",
      "Black Series",
      "Kopi hitam yang dipadukan dengan manis alami kelapa, menghasilkan minuman segar dengan karakter kopi yang tetap terasa.",
      "assets/images/menu_begawan/coconut_americano.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 22727)],
    ),
    OfficialProduct(
      "honey_lemon_americano",
      "Honey Lemon Americano",
      "Black Series",
      "Kopi hitam dengan perpaduan madu dan lemon yang manis serta asam segar, menghadirkan rasa yang seimbang.",
      "assets/images/menu_begawan/honey_lemon_americano.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 22727)],
    ),
    OfficialProduct(
      "orange_americano",
      "Orange Americano",
      "Black Series",
      "Kopi hitam dengan aroma dan rasa jeruk yang segar, menghadirkan sentuhan sitrus pada karakter espresso.",
      "assets/images/menu_begawan/orange_americano.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 22727)],
    ),
    OfficialProduct(
      "cappucino",
      "Cappucino",
      "Milk Based Coffee",
      "Espresso dengan rasa kopi yang kuat, dipadukan busa susu tebal dan lembut untuk tekstur yang terasa ringan di mulut.",
      "assets/images/menu_begawan/cappucino.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 24545)],
    ),
    OfficialProduct(
      "coffee_latte",
      "Coffee Latte",
      "Milk Based Coffee",
      "Espresso dengan susu bertekstur halus dan lembut, menghasilkan minuman kopi susu dengan rasa yang seimbang.",
      "assets/images/menu_begawan/coffee_latte.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 24545)],
    ),
    OfficialProduct(
      "oat_milk_coffee",
      "Oat Milk Coffee",
      "Milk Based Coffee",
      "Espresso satu takaran yang dicampur susu oat bertekstur lembut, menghasilkan sentuhan rasa creamy dalam setiap tegukan.",
      "assets/images/menu_begawan/oat_milk_coffee.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 24545)],
    ),
    OfficialProduct(
      "mochacino",
      "Mochacino",
      "Milk Based Coffee",
      "Perpaduan espresso, cokelat, dan susu lembut yang kaya rasa, cocok untuk pelanggan yang menyukai kopi bercita rasa cokelat.",
      "assets/images/menu_begawan/mochacino.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 26364)],
    ),
    OfficialProduct(
      "salted_caramel_machiato",
      "Salted Caramel Machiato",
      "Milk Based Coffee",
      "Kopi susu karamel lembut dengan tambahan krim kocok di atasnya. Perpaduan espresso dan susu dengan karakter yang lembut.",
      "assets/images/menu_begawan/salted_caramel_machiato.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 26364)],
    ),
    OfficialProduct(
      "affogato",
      "Affogato",
      "Milk Based Coffee",
      "Es krim vanila yang disiram espresso pekat, memadukan rasa manis dan dingin es krim dengan aroma kopi.",
      "assets/images/menu_begawan/affogato.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 28182)],
    ),
    OfficialProduct(
      "tubruk",
      "Tubruk",
      "Manual",
      "Kopi robusta dengan rasa kuat dan karakter pekat, disajikan bersama gula terpisah agar tingkat kemanisan dapat disesuaikan.",
      "assets/images/menu_begawan/tubruk.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 13636)],
    ),
    OfficialProduct(
      "tubruk_susu",
      "Tubruk Susu",
      "Manual",
      "Kopi robusta bercita rasa tegas yang dipadukan susu khas Toko Kopi Jaya, menghadirkan rasa kopi susu yang lebih pekat.",
      "assets/images/menu_begawan/tubruk_susu.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 15455)],
    ),
    OfficialProduct(
      "vietnam_drip",
      "Vietnam Drip",
      "Manual",
      "Kopi seduh tetes khas Vietnam dengan susu kental manis, menyajikan perpaduan rasa kopi pekat dan manis yang khas.",
      "assets/images/menu_begawan/vietnam_drip.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 15455)],
    ),
    OfficialProduct(
      "green_tea_latte",
      "Green Tea Latte",
      "Milk Based",
      "Latte teh hijau dengan rasa lembut, kental, dan aroma teh yang khas. Pilihan minuman susu dengan rasa yang lembut.",
      "assets/images/menu_begawan/green_tea_latte.jpg",
      <OfficialVariant>[
        OfficialVariant("Regular", 15455),
        OfficialVariant("Medium", 20000),
        OfficialVariant("Large", 23636),
      ],
    ),
    OfficialProduct(
      "thai_tea",
      "Thai Tea",
      "Milk Based",
      "Minuman teh Thailand dengan rasa teh yang kuat dan tekstur susu lembut, menghadirkan perpaduan manis serta creamy.",
      "assets/images/menu_begawan/thai_tea.jpg",
      <OfficialVariant>[
        OfficialVariant("Regular", 15455),
        OfficialVariant("Medium", 20000),
        OfficialVariant("Large", 23636),
      ],
    ),
    OfficialProduct(
      "matcha",
      "Matcha",
      "Milk Based",
      "Minuman matcha dengan rasa umami yang kaya dan tekstur lembut, dipadukan manis yang seimbang untuk pengalaman minum yang khas.",
      "assets/images/menu_begawan/matcha.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 32727)],
    ),
    OfficialProduct(
      "milk_tea",
      "Milk Tea",
      "Milk Based",
      "Teh hitam yang dipadukan susu lembut dan creamy, memberikan rasa teh yang tetap terasa di setiap tegukan.",
      "assets/images/menu_begawan/milk_tea.jpg",
      <OfficialVariant>[
        OfficialVariant("Regular", 18182),
        OfficialVariant("Medium", 23636),
        OfficialVariant("Large", 25455),
      ],
    ),
    OfficialProduct(
      "chamomile",
      "Chamomile",
      "Tea",
      "Teh kamomil dengan aroma yang ringan dan karakter lembut, pilihan untuk menikmati minuman hangat yang menenangkan.",
      "assets/images/menu_begawan/chamomile.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 17273)],
    ),
    OfficialProduct(
      "black_tea",
      "Black Tea",
      "Tea",
      "Teh hitam dengan aroma melati yang menyegarkan dan rasa khas teh yang sederhana, cocok dinikmati di berbagai kesempatan.",
      "assets/images/menu_begawan/black_tea.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 17273)],
    ),
    OfficialProduct(
      "greentea_jasmine",
      "Greentea Jasmine",
      "Tea",
      "Teh hijau yang ringan dan menyegarkan dengan aroma bunga melati, menghasilkan rasa teh yang bersih dan harum.",
      "assets/images/menu_begawan/greentea_jasmine.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 17273)],
    ),
    OfficialProduct(
      "lemon_tea",
      "Lemon Tea",
      "Tea",
      "Teh hitam klasik yang dipadukan dengan lemon segar, menghadirkan rasa teh dan sentuhan asam sitrus.",
      "assets/images/menu_begawan/lemon_tea.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 18182)],
    ),
    OfficialProduct(
      "honey_lemon_tea",
      "Honey Lemon Tea",
      "Tea",
      "Teh hitam yang diberi madu dan lemon, menghasilkan rasa manis yang seimbang dengan kesegaran sitrus.",
      "assets/images/menu_begawan/honey_lemon_tea.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 18182)],
    ),
    OfficialProduct(
      "greentea_lemon_mint",
      "Greentea Lemon Mint",
      "Tea",
      "Teh hijau segar yang dipadukan daun mint dan lemon, menghadirkan perpaduan rasa herbal dan sitrus.",
      "assets/images/menu_begawan/greentea_lemon_mint.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 18182)],
    ),
    OfficialProduct(
      "butterfly_sweet_sour",
      "Butterfly Sweet & Sour",
      "Tea",
      "Teh bunga telang dengan daun mint dan lemon; bercita rasa segar, manis, dan asam.",
      "assets/images/menu_begawan/butterfly_sweet_sour.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 18182)],
    ),
    OfficialProduct(
      "lychee_tea",
      "Lychee Tea",
      "Tea",
      "Teh hitam dengan rasa buah leci yang manis dan menyegarkan, cocok untuk pilihan minuman teh beraroma buah.",
      "assets/images/menu_begawan/lychee_tea.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 24545)],
    ),
    OfficialProduct(
      "watermelon_jasmine",
      "Watermelon Jasmine",
      "Tea",
      "Teh hijau beraroma melati dengan kesegaran buah semangka, memadukan karakter teh yang ringan dan buah yang manis.",
      "assets/images/menu_begawan/watermelon_jasmine.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 24545)],
    ),
    OfficialProduct(
      "cucumber_butterfly_pea",
      "Cucumber Butterfly Pea",
      "Tea",
      "Teh bunga telang dengan mentimun yang manis dan menyegarkan. Pilihan teh yang menyegarkan untuk menemani waktu santai.",
      "assets/images/menu_begawan/cucumber_butterfly_pea.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 20000)],
    ),
    OfficialProduct(
      "lemongrass_tea",
      "Lemongrass Tea",
      "Tea",
      "Teh hitam dengan sentuhan aroma serai, menghadirkan minuman teh yang harum dengan karakter rempah yang lembut.",
      "assets/images/menu_begawan/lemongrass_tea.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 20000)],
    ),
    OfficialProduct(
      "ice_shaken_apple_tea",
      "Ice Shaken Apple Tea",
      "Tea",
      "Teh hitam dingin yang dikocok dengan cita rasa apel segar, cocok untuk pelanggan yang menyukai teh bercita rasa buah.",
      "assets/images/menu_begawan/ice_shaken_apple_tea.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 20000)],
    ),
    OfficialProduct(
      "ice_shaken_peach_tea",
      "Ice Shaken Peach Tea",
      "Tea",
      "Teh hitam dingin yang dikocok dengan rasa persik manis, menawarkan kombinasi aroma buah dan kesegaran teh.",
      "assets/images/menu_begawan/ice_shaken_peach_tea.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 20000)],
    ),
    OfficialProduct(
      "almond",
      "Almond",
      "Chocolate",
      "Minuman cokelat yang kaya rasa dengan sentuhan kacang almond yang khas, menghasilkan perpaduan manis dan gurih.",
      "assets/images/menu_begawan/almond.jpg",
      <OfficialVariant>[
        OfficialVariant("Regular", 16364),
        OfficialVariant("Medium", 21819),
        OfficialVariant("Large", 24545),
      ],
    ),
    OfficialProduct(
      "hazelnut",
      "Hazelnut",
      "Chocolate",
      "Minuman cokelat creamy dengan aroma dan cita rasa kacang hazelnut yang lembut, cocok bagi pencinta perpaduan cokelat dan kacang.",
      "assets/images/menu_begawan/hazelnut.jpg",
      <OfficialVariant>[
        OfficialVariant("Regular", 16364),
        OfficialVariant("Medium", 21819),
        OfficialVariant("Large", 24545),
      ],
    ),
    OfficialProduct(
      "original",
      "Original",
      "Chocolate",
      "Minuman cokelat hitam dengan rasa pekat, tekstur creamy, dan karakter cokelat yang kaya dalam setiap tegukan.",
      "assets/images/menu_begawan/original.jpg",
      <OfficialVariant>[
        OfficialVariant("Regular", 16364),
        OfficialVariant("Medium", 21819),
        OfficialVariant("Large", 24545),
      ],
    ),
    OfficialProduct(
      "nasi_goreng_og",
      "Nasi Goreng OG",
      "Main Course",
      "Nasi goreng berbumbu rempah khas Jaya, disajikan dengan sate ayam, kerupuk, acar, dan telur.",
      "assets/images/menu_begawan/nasi_goreng_og.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 36364)],
    ),
    OfficialProduct(
      "mie_goreng_jawa",
      "Mie Goreng Jawa",
      "Main Course",
      "Mie goreng gaya Jawa dengan bumbu gurih, dilengkapi fillet ayam dan telur mata sapi sebagai pelengkap hidangan.",
      "assets/images/menu_begawan/mie_goreng_jawa.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 28182)],
    ),
    OfficialProduct(
      "honey_butter_rice_chicken",
      "Honey Butter Rice Chicken",
      "Main Course",
      "Nasi dengan fillet paha ayam yang dimasak memakai kari racikan rumah beraroma harum, menghasilkan hidangan gurih yang mengenyangkan.",
      "assets/images/menu_begawan/honey_butter_rice_chicken.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 36364)],
    ),
    OfficialProduct(
      "nasi_goreng_kalio",
      "Nasi Goreng Kalio",
      "Main Course",
      "Nasi goreng pedas khas Padang dengan daging sapi dan urat sapi, dilengkapi kol goreng, kerupuk, dan acar.",
      "assets/images/menu_begawan/nasi_goreng_kalio.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 36364)],
    ),
    OfficialProduct(
      "chicken_mentai_rice",
      "Chicken Mentai Rice",
      "Main Course",
      "Ayam panggang dengan saus mentai yang dipanggang hingga kecokelatan dan telur; bercita rasa gurih, lembut, asam segar, dan sedikit pedas.",
      "assets/images/menu_begawan/chicken_mentai_rice.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 36364)],
    ),
    OfficialProduct(
      "chicken_salted_egg",
      "Chicken Salted Egg",
      "Main Course",
      "Ayam goreng renyah yang dibalut saus telur asin bertekstur lembut, dengan perpaduan rasa asin dan gurih yang kaya.",
      "assets/images/menu_begawan/chicken_salted_egg.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 32727)],
    ),
    OfficialProduct(
      "nasi_kandar_ayam",
      "Nasi Kandar Ayam",
      "Main Course",
      "Nasi kandar khas Malaysia yang disajikan dengan ayam goreng di atasnya, menghadirkan perpaduan nasi dan lauk bercita rasa gurih.",
      "assets/images/menu_begawan/nasi_kandar_ayam.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 34545)],
    ),
    OfficialProduct(
      "butter_rice_chicken_omelette_nashville",
      "Butter Rice Chicken Omelette Nashville",
      "Main Course",
      "Nasi mentega berselimut telur dadar, disajikan dengan ayam renyah dan saus Nashville yang pedas.",
      "assets/images/menu_begawan/butter_rice_chicken_omelette_nashville.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 38182)],
    ),
    OfficialProduct(
      "butter_rice_chicken_omelette_teriyaki",
      "Butter Rice Chicken Omelette Teriyaki",
      "Main Course",
      "Nasi mentega berselimut telur dadar dengan ayam renyah dan saus teriyaki manis gurih.",
      "assets/images/menu_begawan/butter_rice_chicken_omelette_teriyaki.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 38182)],
    ),
    OfficialProduct(
      "cabai_garam_6pcs",
      "Cabai Garam (6pcs)",
      "Chicken Wings",
      "Enam potong sayap ayam goreng dengan bawang putih, cabai, dan bumbu pilihan. Disajikan dalam porsi enam potong sesuai menu.",
      "assets/images/menu_begawan/cabai_garam_6pcs.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 32727)],
    ),
    OfficialProduct(
      "homemade_bbq_6pcs",
      "Homemade BBQ (6pcs)",
      "Chicken Wings",
      "Enam potong sayap ayam goreng renyah dengan saus barbeku racikan sendiri. Disajikan dalam porsi enam potong sesuai menu.",
      "assets/images/menu_begawan/homemade_bbq_6pcs.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 32727)],
    ),
    OfficialProduct(
      "garlic_butter_parmesan_6pcs",
      "Garlic Butter Parmesan (6pcs)",
      "Chicken Wings",
      "Enam potong sayap ayam goreng dengan saus mentega bawang putih, cabai, dan taburan keju parmesan.",
      "assets/images/menu_begawan/garlic_butter_parmesan_6pcs.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 32727)],
    ),
    OfficialProduct(
      "margheritta",
      "Margheritta",
      "Pizza Porter",
      "Pizza bergaya klasik dengan tomat segar, daun basil, dan keju mozzarella, menghadirkan rasa yang sederhana namun khas.",
      "assets/images/menu_begawan/margheritta.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 52727)],
    ),
    OfficialProduct(
      "tuna_mentai",
      "Tuna Mentai",
      "Pizza Porter",
      "Pizza dengan topping tuna gurih, saus mayones mentai pedas, dan keju yang menyatu dalam setiap potongan.",
      "assets/images/menu_begawan/tuna_mentai.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 58182)],
    ),
    OfficialProduct(
      "meat_lover",
      "Meat Lover",
      "Pizza Porter",
      "Pizza dengan perpaduan topping daging yang kaya rasa dan gurih, cocok untuk pelanggan yang menyukai hidangan berdaging.",
      "assets/images/menu_begawan/meat_lover.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 58182)],
    ),
    OfficialProduct(
      "el_mushroom_with_truffle_paste",
      "El Mushroom with Truffle Paste",
      "Pizza Porter",
      "Pizza dengan perpaduan jamur, pasta truffle beraroma khas, dan keju mozzarella. Perpaduan topping dan adonan pizza khas Toko Kopi Jaya.",
      "assets/images/menu_begawan/el_mushroom_with_truffle_paste.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 58182)],
    ),
    OfficialProduct(
      "quattro_formaggi",
      "Quattro Formaggi",
      "Pizza Porter",
      "Pizza dengan keju mozzarella, parmesan, cheddar, dan mascarpone serta sentuhan madu. Perpaduan topping dan adonan pizza khas Toko Kopi Jaya.",
      "assets/images/menu_begawan/quattro_formaggi.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 56364)],
    ),
    OfficialProduct(
      "pepperoni",
      "Pepperoni",
      "Pizza Porter",
      "Pizza dengan topping irisan pepperoni bercita rasa gurih yang khas, menjadi pilihan bagi pencinta pizza klasik.",
      "assets/images/menu_begawan/pepperoni.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 56364)],
    ),
    OfficialProduct(
      "handcut_fries_w_coffee_sauce",
      "Handcut Fries w/ Coffee Sauce",
      "Snack",
      "Kentang goreng potong tangan dengan saus kopi manis khas Jaya. Pilihan camilan untuk menemani waktu santai.",
      "assets/images/menu_begawan/handcut_fries_w_coffee_sauce.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 18182)],
    ),
    OfficialProduct(
      "potato_wedges",
      "Potato Wedges",
      "Snack",
      "Potongan kentang tebal yang digoreng hingga matang dan disajikan bersama saus BBQ untuk cita rasa gurih yang lebih lengkap.",
      "assets/images/menu_begawan/potato_wedges.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 18182)],
    ),
    OfficialProduct(
      "cireng",
      "Cireng",
      "Snack",
      "Camilan cireng berbahan tapioka yang digoreng hingga renyah di luar, lalu disajikan bersama saus Bangkok bercita rasa khas.",
      "assets/images/menu_begawan/cireng.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 15455)],
    ),
    OfficialProduct(
      "tahu_bakso",
      "Tahu Bakso",
      "Snack",
      "Tahu berisi cincangan ayam dan udang, dikukus lalu digoreng hingga keemasan. Pilihan camilan untuk menemani waktu santai.",
      "assets/images/menu_begawan/tahu_bakso.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 18182)],
    ),
    OfficialProduct(
      "gyoza",
      "Gyoza",
      "Snack",
      "Pangsit gurih berisi daging ayam dan udang, dimasak hingga lezat lalu disajikan bersama saus Bangkok sebagai pelengkap.",
      "assets/images/menu_begawan/gyoza.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 24545)],
    ),
    OfficialProduct(
      "classic_popcorn",
      "Classic Popcorn",
      "Snack",
      "Popcorn ringan dan renyah dengan bumbu asin gurih klasik, cocok sebagai camilan sederhana saat menikmati waktu di kafe.",
      "assets/images/menu_begawan/classic_popcorn.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 22727)],
    ),
    OfficialProduct(
      "jaya_mix_platter",
      "Jaya Mix Platter",
      "Snack",
      "Paket camilan untuk berbagi berisi cireng, kentang goreng, gyoza, tahu bakso, dan olahan kentang, dengan saus barbeku dan Bangkok.",
      "assets/images/menu_begawan/jaya_mix_platter.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 45455)],
    ),
    OfficialProduct(
      "tahu_cireng_gejrot",
      "Tahu Cireng Gejrot",
      "Snack",
      "Perpaduan tahu bakso dan cireng dengan saus gejrot yang pedas, asam, manis, dan gurih.",
      "assets/images/menu_begawan/tahu_cireng_gejrot.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 29091)],
    ),
    OfficialProduct(
      "chicken_strip_with_mushroom_bechamel",
      "Chicken Strip with Mushroom Bechamel",
      "Snack",
      "Potongan ayam goreng renyah dengan saus jamur yang lembut dan minyak bayam. Pilihan camilan untuk menemani waktu santai.",
      "assets/images/menu_begawan/chicken_strip_with_mushroom_bechamel.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 32727)],
    ),
    OfficialProduct(
      "chicken_strip_with_creamy_nashville_sauce",
      "Chicken Strip with Creamy Nashville Sauce",
      "Snack",
      "Potongan ayam goreng renyah dengan saus Nashville yang lembut dan pedas. Pilihan camilan untuk menemani waktu santai.",
      "assets/images/menu_begawan/chicken_strip_with_creamy_nashville_sauce.jpg",
      <OfficialVariant>[OfficialVariant("Standar", 32727)],
    ),
    OfficialProduct(
      "mineral_water",
      "Mineral Water",
      "Add On",
      "Air mineral untuk melengkapi pesanan. Dapat dipilih sebagai tambahan yang sesuai dengan menu utama.",
      null,
      <OfficialVariant>[OfficialVariant("Satuan", 7273)],
    ),
    OfficialProduct(
      "extra_shot",
      "Extra Shot",
      "Add On",
      "Tambahan satu takaran espresso pada minuman kopi. Dapat dipilih sebagai tambahan yang sesuai dengan menu utama.",
      null,
      <OfficialVariant>[OfficialVariant("Satuan", 8182)],
    ),
    OfficialProduct(
      "gula_aren",
      "Gula Aren",
      "Add On",
      "Tambahan pemanis gula aren untuk minuman. Dapat dipilih sebagai tambahan yang sesuai dengan menu utama.",
      null,
      <OfficialVariant>[OfficialVariant("Satuan", 3636)],
    ),
    OfficialProduct(
      "whip_cream",
      "Whip Cream",
      "Add On",
      "Tambahan krim kocok untuk minuman. Dapat dipilih sebagai tambahan yang sesuai dengan menu utama.",
      null,
      <OfficialVariant>[OfficialVariant("Satuan", 4545)],
    ),
    OfficialProduct(
      "madu",
      "Madu",
      "Add On",
      "Tambahan madu untuk minuman. Dapat dipilih sebagai tambahan yang sesuai dengan menu utama.",
      null,
      <OfficialVariant>[OfficialVariant("Satuan", 6364)],
    ),
    OfficialProduct(
      "nasi_uduk",
      "Nasi Uduk",
      "Add On",
      "Tambahan satu porsi nasi uduk. Dapat dipilih sebagai tambahan yang sesuai dengan menu utama.",
      null,
      <OfficialVariant>[OfficialVariant("Satuan", 5455)],
    ),
    OfficialProduct(
      "sunny_side_up_egg",
      "Sunny Side Up Egg",
      "Add On",
      "Tambahan satu telur mata sapi. Dapat dipilih sebagai tambahan yang sesuai dengan menu utama.",
      null,
      <OfficialVariant>[OfficialVariant("Satuan", 5455)],
    ),
    OfficialProduct(
      "chili_sauce",
      "Chili Sauce",
      "Add On",
      "Tambahan saus cabai. Dapat dipilih sebagai tambahan yang sesuai dengan menu utama.",
      null,
      <OfficialVariant>[OfficialVariant("Satuan", 3636)],
    ),
    OfficialProduct(
      "bangkok_sauce",
      "Bangkok Sauce",
      "Add On",
      "Tambahan saus Bangkok. Dapat dipilih sebagai tambahan yang sesuai dengan menu utama.",
      null,
      <OfficialVariant>[OfficialVariant("Satuan", 4545)],
    ),
    OfficialProduct(
      "chili_oil",
      "Chili Oil",
      "Add On",
      "Tambahan minyak cabai. Dapat dipilih sebagai tambahan yang sesuai dengan menu utama.",
      null,
      <OfficialVariant>[OfficialVariant("Satuan", 4545)],
    ),
    OfficialProduct(
      "bbq_sauce",
      "BBQ Sauce",
      "Add On",
      "Tambahan saus barbeku. Dapat dipilih sebagai tambahan yang sesuai dengan menu utama.",
      null,
      <OfficialVariant>[OfficialVariant("Satuan", 6364)],
    ),
    OfficialProduct(
      "coffee_sauce",
      "Coffee Sauce",
      "Add On",
      "Tambahan saus kopi khas Jaya. Dapat dipilih sebagai tambahan yang sesuai dengan menu utama.",
      null,
      <OfficialVariant>[OfficialVariant("Satuan", 6364)],
    ),
  ];
  static OfficialProduct? byName(String name) {
    for (final menu in menus) {
      if (menu.name == name) return menu;
    }
    return null;
  }

  static OfficialProduct? byId(String id) {
    for (final menu in menus) {
      if (menu.id == id) return menu;
    }
    return null;
  }

  static String rupiah(int price) {
    final digits = price.toString();
    return 'Rp ${digits.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  static List<String> relevantAddons(OfficialProduct menu) {
    if (menu.category == 'Add On') return const [];
    if (const [
      'Signature',
      'Manual',
      'Black Series',
      'Milk Based Coffee',
    ].contains(menu.category)) {
      return const ['Extra Shot', 'Gula Aren', 'Whip Cream', 'Madu'];
    }
    if (const [
      'Tea',
      'Milk Based',
      'Chocolate',
      'Milkshake',
    ].contains(menu.category)) {
      return const ['Gula Aren', 'Whip Cream', 'Madu'];
    }
    if (menu.category == 'Main Course') {
      return const [
        'Nasi Uduk',
        'Sunny Side Up Egg',
        'Chili Sauce',
        'Chili Oil',
      ];
    }
    if (menu.category == 'Pizza Porter')
      return const ['Chili Oil', 'Chili Sauce'];
    if (menu.category == 'Chicken Wings' ||
        menu.category == 'Snack' ||
        menu.category == 'JMX Platter') {
      return const [
        'Chili Sauce',
        'Bangkok Sauce',
        'BBQ Sauce',
        'Coffee Sauce',
        'Chili Oil',
      ];
    }
    return const [];
  }

  static List<OfficialAddon> availableAddonsFor(OfficialProduct m) {
    return relevantAddons(m)
        .map((n) => OfficialAddon(n, addOnPrices[n] ?? 0))
        .toList();
  }

  static String formatRupiah(int value) => rupiah(value);
  static const allowHistoricalPrototypeOrder = true;
  static List<Map<String, String>> get referenceProducts {
    return menus
        .where((m) => m.category != 'Add On')
        .map(
          (m) => <String, String>{
            'name': m.name,
            'description': m.description,
            'price': m.variants.length == 1
                ? rupiah(m.lowestPrice)
                : 'Mulai ${rupiah(m.lowestPrice)}',
            'category': m.category,
            'subcategory': m.category,
            'image': m.image ?? 'assets/images/tap_jaya_logo.png',
            'reference': 'true',
          },
        )
        .toList(growable: false);
  }
}
