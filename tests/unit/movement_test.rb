def current_user
  @user ||= User.with :name, 'alagranja'
  @user ||= User.create name: 'alagranja', password: 'alagranja'
end

def deposit
  Movement.create price: 3000, type: 'Deposit'
end

def old_deposit
  Movement.create price: 100, type: 'Deposit', created_at: Time.now - 60 * 60 * 24
end

def extraction
  Movement.create price: 3100.25, type: 'Extraction'
end

def mock_session
  get '/movements', {}, { 'rack.session' => { user_id: current_user.id } }
end

scope do
  mock_session

  test 'show all movements' do
    get '/movements'
    assert_equal 200, last_response.status
  end

  test 'show a movement' do
    id = deposit.id
    get "/movements/#{id}"
    assert_equal 200, last_response.status
  end

  test 'show all movements for current_user' do
    #TODO
  end

  test 'create a movement' do
    post '/movements', { movement: { price: 3000, description: 'increase', type: 'Deposit' } }
    assert_equal 1, Movement.all.count
  end

  test 'update a movement' do
    id = deposit.id
    put "/movements/#{id}", { movement: { price: 100 } }
    assert_equal 100, Movement[id].price.to_i
  end

  test 'delete a movement' do
    id = deposit.id
    delete "/movements/#{id}"
    assert_equal 0, Movement.all.count
  end

  test 'not permited update or delete a movement' do
    id = old_deposit.id
    delete "/movements/#{id}"
    assert_equal 401, last_response.status
  end

  test 'calculace total with no movements' do
    assert_equal 0, Cuba.new.calculate_total
  end

  test 'calculate total, deposits only' do
    deposit
    assert_equal -3000, Cuba.new.calculate_total
  end

  test 'calculate total with deposit in favour' do
    deposit
    old_deposit
    extraction
    assert_equal 0.25, Cuba.new.calculate_total
  end
end