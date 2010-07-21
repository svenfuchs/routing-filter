module Recognition
  # 1 filter

  test 'recognizes the path /some.html (extension)' do
    params = self.params
    assert_equal params, routes.recognize_path('/some.html')
  end

  test 'recognizes the path /de/some (locale)' do
    params = self.params.merge(:locale => 'de')
    assert_equal params, routes.recognize_path('/de/some')
  end

  test 'recognizes the path /some/page/2 (pagination)' do
    params = self.params.merge(:page => 2)
    assert_equal params, routes.recognize_path('/some/page/2')
  end

  test 'recognizes the path /:uuid/some (uuid)' do
    params = self.params.merge(:uuid => uuid)
    assert_equal params, routes.recognize_path("/#{uuid}/some")
  end
  
  # extension with any

  test 'recognizes the path /de/some.html (extension, locale)' do
    params = self.params.merge(:locale => 'de')
    assert_equal params, routes.recognize_path('/de/some.html')
  end

  test 'recognizes the path /some/page/2.html (extension, pagination)' do
    params = self.params.merge(:page => 2)
    assert_equal params, routes.recognize_path('/some/page/2.html')
  end

  test 'recognizes the path /:uuid/some.html (extension, uuid)' do
    params = self.params.merge(:uuid => uuid)
    assert_equal params, routes.recognize_path("/#{uuid}/some.html")
  end

  # locale with any

  test 'recognizes the path /de/some/page/2 (locale, pagination)' do
    params = self.params.merge(:locale => 'de', :page => 2)
    assert_equal params, routes.recognize_path('/de/some/page/2')
  end

  test 'recognizes the path /de/:uuid/some (locale, uuid)' do
    params = self.params.merge(:locale => 'de', :uuid => uuid)
    assert_equal params, routes.recognize_path("/de/#{uuid}/some")
  end

  # pagination with any

  test 'recognizes the path /:uuid/some/page/2 (pagination, uuid)' do
    params = self.params.merge(:page => 2, :uuid => uuid)
    assert_equal params, routes.recognize_path("/#{uuid}/some/page/2")
  end

  # extension, locale with any

  test 'recognizes the path /de/some/page/2.html (extension, locale, pagination)' do
    params = self.params.merge(:locale => 'de', :page => 2)
    assert_equal params, routes.recognize_path("/de/some/page/2.html")
  end

  test 'recognizes the path /de/:uuid/some.html (extension, locale, uuid)' do
    params = self.params.merge(:locale => 'de', :uuid => uuid)
    assert_equal params, routes.recognize_path("/de/#{uuid}/some.html")
  end
  
  # extension, pagination with any

  test 'recognizes the path /some/page/2.html (extension, pagination, uuid)' do
    params = self.params.merge(:page => 2, :uuid => uuid)
    assert_equal params, routes.recognize_path("/#{uuid}/some/page/2.html")
  end
  
  # locale, pagination with any

  test 'recognizes the path /de/some/page/2 (locale, pagination, uuid)' do
    params = self.params.merge(:locale => 'de', :page => 2, :uuid => uuid)
    assert_equal params, routes.recognize_path("/de/#{uuid}/some/page/2")
  end
  
  # all

  test 'recognizes the path /de/:uuid/some/page/2.html (extension, locale, pagination, uuid)' do
    params = self.params.merge(:locale => 'de', :page => 2, :uuid => uuid)
    assert_equal params, routes.recognize_path("/de/#{uuid}/some/page/2.html")
  end
end