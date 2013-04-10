require 'pact/producer/rspec'

describe "the match_term matcher" do

  it 'does not match a hash to an array' do
    expect({}).to_not match_term([])
  end

  it 'does not match an array to a hash' do
    expect([]).to_not match_term({})
  end

  it 'matches regular expressions' do
    expect('blah').to match_term(/[a-z]*/)
  end

  it 'matches pact terms' do
    expect('wootle').to match_term Pact::Term.new(generate:'wootle', match:/woot../)
  end

  it 'matches all elements of arrays' do
    expect(['one', 'two', ['three']]).to match_term [/one/, 'two', [Pact::Term.new(generate:'three', match:/thr../)]]
  end

  it 'matches all values of hashes' do
    expect({1 => 'one', 2 => 2, 3 => 'three'}).to match_term({1 => /one/, 2 => 2, 3 => Pact::Term.new(generate:'three', match:/thr../)})
  end

  it 'matches all other objects using ==' do
    expect('wootle').to match_term 'wootle'
  end

end