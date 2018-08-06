import Css
import Html
import Styleguide

extension Stripe {
  public enum html {
    public static let formId = "card-form"

    public static func cardInput(expand: Bool) -> [Node] {
      return [
        input([name("token"), type(.hidden)]),
        div([`class`(expand ? [] : [Class.display.none])], [
          input([
            `class`([blockInputClass]),
            name("stripe_name"),
            placeholder("Billing Name"),
            type(.text),
            ]),
          input([
            `class`([blockInputClass]),
            name("stripe_address_line1"),
            placeholder("Address"),
            type(.text),
            ]),
          gridRow([
            gridColumn(sizes: [.mobile: 12, .desktop: 4], [
              div([`class`([Class.padding([.desktop: [.right: 1]])])], [
                input([
                  `class`([blockInputClass]),
                  name("stripe_address_city"),
                  placeholder("City"),
                  type(.text),
                  ])
                ])
              ]),
            gridColumn(sizes: [.mobile: 12, .desktop: 3], [
              div([`class`([Class.padding([.desktop: [.leftRight: 1]])])], [
                input([
                  `class`([blockInputClass]),
                  name("stripe_address_state"),
                  placeholder("State"),
                  type(.text),
                  ])
                ])
              ]),
            gridColumn(sizes: [.mobile: 12, .desktop: 2], [
              div([`class`([Class.padding([.desktop: [.leftRight: 1]])])], [
                input([
                  `class`([blockInputClass]),
                  name("stripe_address_zip"),
                  placeholder("Zip"),
                  type(.text),
                  ]),
                ])
              ]),
            gridColumn(sizes: [.mobile: 12, .desktop: 3], [
              div([`class`([Class.padding([.desktop: [.left: 1]])])], [
                select([`class`([blockSelectClass]), name("stripe_address_country")], [option([disabled(true), selected(true), value("")], "Country")] + countries.map { pair in
                  let (country, code) = pair
                  return option([value(code)], country)
                })
                ]),
              ]),
            ]),
          input([
            `class`([blockInputClass]),
            name("vatNumber"),
            placeholder("VAT Number (EU Customers Only)"),
            type(.text),
            ]),
          input([
            `class`([blockInputClass]),
            name("coupon"),
            placeholder("Coupon Code"),
            type(.text),
            ]),
          ]),
        div(
          [
            `class`([stripeInputClass]),
            data("stripe-key", Current.envVars.stripe.publishableKey),
            id("card-element"),
          ],
          []
        )
      ]
    }

    public static let errors = [
      div(
        [
          `class`([Class.pf.colors.fg.red]),
          id("card-errors"),
          role(.alert),
        ],
        []
      )
    ]

    public static var scripts: [Node] {
      return [
        script([src(Current.stripe.js)]),
        script(
          """
          function setFormEnabled(form, isEnabled, elementsMatching) {
            for (var idx = 0; idx < form.length; idx++) {
              var formElement = form[idx];
              if (elementsMatching(formElement)) {
                formElement.disabled = !isEnabled;
                if (formElement.tagName == 'BUTTON') {
                  formElement.textContent = isEnabled ? 'Subscribe to Point‑Free' : 'Subscribing…';
                }
              }
            }
          }

          var apiKey = document.getElementById('card-element').dataset.stripeKey;
          var stripe = Stripe(apiKey);
          var elements = stripe.elements();

          var style = {
            base: {
              color: '#32325d',
              fontSize: '16px',
            }
          };

          var card = elements.create('card', {style: style});
          card.mount('#card-element');

          card.addEventListener('change', function(event) {
            var displayError = document.getElementById('card-errors');
            if (event.error) {
              displayError.textContent = event.error.message;
            } else {
              displayError.textContent = '';
            }
          });

          var form = document.getElementById('card-form');
          form.addEventListener('submit', function(event) {
            event.preventDefault();

            setFormEnabled(form, false, function() {
              return true;
            });

            stripe.createToken(
              card,
              {
                name: form.stripe_name.value,
                address_line1: form.stripe_address_line1.value,
                address_city: form.stripe_address_city.value,
                address_state: form.stripe_address_state.value,
                address_zip: form.stripe_address_zip.value,
                address_country: form.stripe_address_country.value
              }
            ).then(function(result) {
              if (result.error) {
                var errorElement = document.getElementById('card-errors');
                errorElement.textContent = result.error.message;

                setFormEnabled(form, true, function(el) {
                  return true;
                });
              } else {
                setFormEnabled(form, true, function(el) {
                  return el.tagName != 'BUTTON';
                });

                form.token.value = result.token.id;
                form.submit();
              }
            }).catch(function() {
              setFormEnabled(form, true, function(el) {
                return true;
              });
            });
          });
          """
        )
      ]
    }
  }
}

private let stripeInputClass =
  regularInputClass
    | Class.flex.column
    | Class.flex.flex
    | Class.flex.justify.center
    | Class.size.width100pct

private let countries: [(String, String)] = [
  ("Afghanistan", "AF"),
  ("Åland Islands", "AX"),
  ("Albania", "AL"),
  ("Algeria", "DZ"),
  ("American Samoa", "AS"),
  ("Andorra", "AD"),
  ("Angola", "AO"),
  ("Anguilla", "AI"),
  ("Antarctica", "AQ"),
  ("Antigua and Barbuda", "AG"),
  ("Argentina", "AR"),
  ("Armenia", "AM"),
  ("Aruba", "AW"),
  ("Australia", "AU"),
  ("Austria", "AT"),
  ("Azerbaijan", "AZ"),
  ("Bahamas", "BS"),
  ("Bahrain", "BH"),
  ("Bangladesh", "BD"),
  ("Barbados", "BB"),
  ("Belarus", "BY"),
  ("Belgium", "BE"),
  ("Belize", "BZ"),
  ("Benin", "BJ"),
  ("Bermuda", "BM"),
  ("Bhutan", "BT"),
  ("Bolivia, Plurinational State of", "BO"),
  ("Bonaire, Sint Eustatius and Saba", "BQ"),
  ("Bosnia and Herzegovina", "BA"),
  ("Botswana", "BW"),
  ("Bouvet Island", "BV"),
  ("Brazil", "BR"),
  ("British Indian Ocean Territory", "IO"),
  ("Brunei Darussalam", "BN"),
  ("Bulgaria", "BG"),
  ("Burkina Faso", "BF"),
  ("Burundi", "BI"),
  ("Cambodia", "KH"),
  ("Cameroon", "CM"),
  ("Canada", "CA"),
  ("Cape Verde", "CV"),
  ("Cayman Islands", "KY"),
  ("Central African Republic", "CF"),
  ("Chad", "TD"),
  ("Chile", "CL"),
  ("China", "CN"),
  ("Christmas Island", "CX"),
  ("Cocos (Keeling) Islands", "CC"),
  ("Colombia", "CO"),
  ("Comoros", "KM"),
  ("Congo", "CG"),
  ("Congo, the Democratic Republic of the", "CD"),
  ("Cook Islands", "CK"),
  ("Costa Rica", "CR"),
  ("Côte d'Ivoire", "CI"),
  ("Croatia", "HR"),
  ("Cuba", "CU"),
  ("Curaçao", "CW"),
  ("Cyprus", "CY"),
  ("Czech Republic", "CZ"),
  ("Denmark", "DK"),
  ("Djibouti", "DJ"),
  ("Dominica", "DM"),
  ("Dominican Republic", "DO"),
  ("Ecuador", "EC"),
  ("Egypt", "EG"),
  ("El Salvador", "SV"),
  ("Equatorial Guinea", "GQ"),
  ("Eritrea", "ER"),
  ("Estonia", "EE"),
  ("Ethiopia", "ET"),
  ("Falkland Islands (Malvinas)", "FK"),
  ("Faroe Islands", "FO"),
  ("Fiji", "FJ"),
  ("Finland", "FI"),
  ("France", "FR"),
  ("French Guiana", "GF"),
  ("French Polynesia", "PF"),
  ("French Southern Territories", "TF"),
  ("Gabon", "GA"),
  ("Gambia", "GM"),
  ("Georgia", "GE"),
  ("Germany", "DE"),
  ("Ghana", "GH"),
  ("Gibraltar", "GI"),
  ("Greece", "GR"),
  ("Greenland", "GL"),
  ("Grenada", "GD"),
  ("Guadeloupe", "GP"),
  ("Guam", "GU"),
  ("Guatemala", "GT"),
  ("Guernsey", "GG"),
  ("Guinea", "GN"),
  ("Guinea-Bissau", "GW"),
  ("Guyana", "GY"),
  ("Haiti", "HT"),
  ("Heard Island and McDonald Islands", "HM"),
  ("Holy See (Vatican City State)", "VA"),
  ("Honduras", "HN"),
  ("Hong Kong", "HK"),
  ("Hungary", "HU"),
  ("Iceland", "IS"),
  ("India", "IN"),
  ("Indonesia", "ID"),
  ("Iran, Islamic Republic of", "IR"),
  ("Iraq", "IQ"),
  ("Ireland", "IE"),
  ("Isle of Man", "IM"),
  ("Israel", "IL"),
  ("Italy", "IT"),
  ("Jamaica", "JM"),
  ("Japan", "JP"),
  ("Jersey", "JE"),
  ("Jordan", "JO"),
  ("Kazakhstan", "KZ"),
  ("Kenya", "KE"),
  ("Kiribati", "KI"),
  ("Korea, Democratic People's Republic of", "KP"),
  ("Korea, Republic of", "KR"),
  ("Kuwait", "KW"),
  ("Kyrgyzstan", "KG"),
  ("Lao People's Democratic Republic", "LA"),
  ("Latvia", "LV"),
  ("Lebanon", "LB"),
  ("Lesotho", "LS"),
  ("Liberia", "LR"),
  ("Libya", "LY"),
  ("Liechtenstein", "LI"),
  ("Lithuania", "LT"),
  ("Luxembourg", "LU"),
  ("Macao", "MO"),
  ("Macedonia, the former Yugoslav Republic of", "MK"),
  ("Madagascar", "MG"),
  ("Malawi", "MW"),
  ("Malaysia", "MY"),
  ("Maldives", "MV"),
  ("Mali", "ML"),
  ("Malta", "MT"),
  ("Marshall Islands", "MH"),
  ("Martinique", "MQ"),
  ("Mauritania", "MR"),
  ("Mauritius", "MU"),
  ("Mayotte", "YT"),
  ("Mexico", "MX"),
  ("Micronesia, Federated States of", "FM"),
  ("Moldova, Republic of", "MD"),
  ("Monaco", "MC"),
  ("Mongolia", "MN"),
  ("Montenegro", "ME"),
  ("Montserrat", "MS"),
  ("Morocco", "MA"),
  ("Mozambique", "MZ"),
  ("Myanmar", "MM"),
  ("Namibia", "NA"),
  ("Nauru", "NR"),
  ("Nepal", "NP"),
  ("Netherlands", "NL"),
  ("New Caledonia", "NC"),
  ("New Zealand", "NZ"),
  ("Nicaragua", "NI"),
  ("Niger", "NE"),
  ("Nigeria", "NG"),
  ("Niue", "NU"),
  ("Norfolk Island", "NF"),
  ("Northern Mariana Islands", "MP"),
  ("Norway", "NO"),
  ("Oman", "OM"),
  ("Pakistan", "PK"),
  ("Palau", "PW"),
  ("Palestinian Territory, Occupied", "PS"),
  ("Panama", "PA"),
  ("Papua New Guinea", "PG"),
  ("Paraguay", "PY"),
  ("Peru", "PE"),
  ("Philippines", "PH"),
  ("Pitcairn", "PN"),
  ("Poland", "PL"),
  ("Portugal", "PT"),
  ("Puerto Rico", "PR"),
  ("Qatar", "QA"),
  ("Réunion", "RE"),
  ("Romania", "RO"),
  ("Russian Federation", "RU"),
  ("Rwanda", "RW"),
  ("Saint Barthélemy", "BL"),
  ("Saint Helena, Ascension and Tristan da Cunha", "SH"),
  ("Saint Kitts and Nevis", "KN"),
  ("Saint Lucia", "LC"),
  ("Saint Martin (French part)", "MF"),
  ("Saint Pierre and Miquelon", "PM"),
  ("Saint Vincent and the Grenadines", "VC"),
  ("Samoa", "WS"),
  ("San Marino", "SM"),
  ("Sao Tome and Principe", "ST"),
  ("Saudi Arabia", "SA"),
  ("Senegal", "SN"),
  ("Serbia", "RS"),
  ("Seychelles", "SC"),
  ("Sierra Leone", "SL"),
  ("Singapore", "SG"),
  ("Sint Maarten (Dutch part)", "SX"),
  ("Slovakia", "SK"),
  ("Slovenia", "SI"),
  ("Solomon Islands", "SB"),
  ("Somalia", "SO"),
  ("South Africa", "ZA"),
  ("South Georgia and the South Sandwich Islands", "GS"),
  ("South Sudan", "SS"),
  ("Spain", "ES"),
  ("Sri Lanka", "LK"),
  ("Sudan", "SD"),
  ("Suriname", "SR"),
  ("Svalbard and Jan Mayen", "SJ"),
  ("Swaziland", "SZ"),
  ("Sweden", "SE"),
  ("Switzerland", "CH"),
  ("Syrian Arab Republic", "SY"),
  ("Taiwan, Province of China", "TW"),
  ("Tajikistan", "TJ"),
  ("Tanzania, United Republic of", "TZ"),
  ("Thailand", "TH"),
  ("Timor-Leste", "TL"),
  ("Togo", "TG"),
  ("Tokelau", "TK"),
  ("Tonga", "TO"),
  ("Trinidad and Tobago", "TT"),
  ("Tunisia", "TN"),
  ("Turkey", "TR"),
  ("Turkmenistan", "TM"),
  ("Turks and Caicos Islands", "TC"),
  ("Tuvalu", "TV"),
  ("Uganda", "UG"),
  ("Ukraine", "UA"),
  ("United Arab Emirates", "AE"),
  ("United Kingdom", "GB"),
  ("United States", "US"),
  ("United States Minor Outlying Islands", "UM"),
  ("Uruguay", "UY"),
  ("Uzbekistan", "UZ"),
  ("Vanuatu", "VU"),
  ("Venezuela, Bolivarian Republic of", "VE"),
  ("Viet Nam", "VN"),
  ("Virgin Islands, British", "VG"),
  ("Virgin Islands, U.S.", "VI"),
  ("Wallis and Futuna", "WF"),
  ("Western Sahara", "EH"),
  ("Yemen", "YE"),
  ("Zambia", "ZM"),
  ("Zimbabwe", "ZW"),
]
