require File.join(File.dirname(__FILE__), 'test_base_geocoder')

Geokit::Geocoders::yandex = 'Yandex'

class YandexGeocoderTest < BaseGeocoderTest #:nodoc: all
    YANDEX_FULL=<<-EOF.strip
<?xml version="1.0" encoding="utf-8"?>
<ymaps xmlns="http://maps.yandex.ru/ymaps/1.x">
  <GeoObjectCollection>
    <metaDataProperty xmlns="http://www.opengis.net/gml">
      <GeocoderResponseMetaData xmlns="http://maps.yandex.ru/geocoder/1.x">
        <request>Владимир, ул. Октябрьская, д.4</request>
        <found>1</found>
      </GeocoderResponseMetaData>
    </metaDataProperty>

    <featureMember xmlns="http://www.opengis.net/gml">
      <GeoObject xmlns="http://maps.yandex.ru/ymaps/1.x">
        <metaDataProperty xmlns="http://www.opengis.net/gml">
          <GeocoderMetaData xmlns="http://maps.yandex.ru/geocoder/1.x">
            <kind>house</kind>
            <text>Россия, Владимирская область, Владимир, улица Октябрьская, 4</text>
            <precision>exact</precision>

            <AddressDetails xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0">
              <Country>
                <CountryName>Россия</CountryName>
                <AdministrativeArea>
                  <AdministrativeAreaName>Владимирская область</AdministrativeAreaName>
                  <Locality>
                    <LocalityName>Владимир</LocalityName>

                    <Thoroughfare>
                      <ThoroughfareName>улица Октябрьская</ThoroughfareName>
                      <Premise>
                        <PremiseNumber>4</PremiseNumber>
                      </Premise>
                    </Thoroughfare>
                  </Locality>
                </AdministrativeArea>

              </Country>
            </AddressDetails>
          </GeocoderMetaData>
        </metaDataProperty>
        <boundedBy xmlns="http://www.opengis.net/gml">
          <Envelope>
            <lowerCorner>40.394804 56.124582</lowerCorner>
            <upperCorner>40.411261 56.130713</upperCorner>

          </Envelope>
        </boundedBy>
        <Point xmlns="http://www.opengis.net/gml">
          <pos>40.403032 56.127648</pos>
        </Point>
      </GeoObject>
    </featureMember>
  </GeoObjectCollection>

</ymaps>

    EOF

  def setup
    super
    @address = "Владимир, ул. Октябрьская, 4"
    @yandex_full_hash = {:street_address=>"улица Октябрьская", :city=>"Владимир", :state=>"Владимирская область", :country_code=>"RU",
       :lng => "40.403032", :lat => "56.127648"}
    @yandex_full_loc = Geokit::GeoLoc.new(@yandex_full_hash)
  end

  # the testing methods themselves
  def test_yandex_full_address
    response = MockSuccess.new
    response.expects(:body).returns(YANDEX_FULL)
    url="http://geocode-maps.yandex.ru/1.x/?key=#{Geokit::Geocoders::yandex}&geocode=#{Geokit::Inflector::url_escape(@address)}"
    Geokit::Geocoders::YandexGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    result = Geokit::Geocoders::YandexGeocoder.geocode(@address)

    assert_equal @yandex_full_loc.city, result.city
    assert_equal @yandex_full_loc.lng, result.lng
    assert_equal @yandex_full_loc.lat, result.lat
    assert_equal @yandex_full_loc.country_code, result.country_code
    assert_equal @yandex_full_loc.street_address, result.street_address
    assert_equal @yandex_full_loc.state, result.state

  end

  def test_service_unavailable
    response = MockFailure.new
    url="http://geocode-maps.yandex.ru/1.x/?key=#{Geokit::Geocoders::yandex}&geocode=#{Geokit::Inflector::url_escape(@address)}"
    Geokit::Geocoders::YandexGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert !Geokit::Geocoders::YandexGeocoder.geocode(@address).success
  end

end