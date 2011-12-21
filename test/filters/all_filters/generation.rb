module Generation
  test 'generates the path /some.html (extension)' do
    params = self.params
    assert_generates '/some.html', routes.generate(params)
  end
  
  # extension with any
  
  test 'generates the path /de/some (extension, locale)' do
    params = self.params.merge(:locale => 'de')
    assert_generates '/de/some.html', routes.generate(params)
  end

  test 'generates the path /some/page/2 (extension, pagination)' do
    params = self.params.merge(:page => 2)
    assert_generates '/some/page/2.html', routes.generate(params)
  end

  test 'generates the path /:uuid/some (extension, uuid)' do
    params = self.params.merge(:uuid => uuid)
    assert_generates "/#{uuid}/some.html", routes.generate(params)
  end
  
  # extension, locale with any
  
  test 'generates the path /de/some/page/2 (extension, locale, pagination)' do
    params = self.params.merge(:locale => 'de', :page => 2)
    assert_generates '/de/some/page/2.html', routes.generate(params)
  end
  
  test 'generates the path /de/:uuid/some (extension, locale, uuid)' do
    params = self.params.merge(:locale => 'de', :uuid => uuid)
    assert_generates "/de/#{uuid}/some.html", routes.generate(params)
  end
  
  # all
  
  test 'generates the path /de/some/page/2 (extension, pagination, uuid)' do
    params = self.params.merge(:locale => 'de', :page => 2, :uuid => uuid)
    assert_generates "/de/#{uuid}/some/page/2.html", routes.generate(params)
  end
end
