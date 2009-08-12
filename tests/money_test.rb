$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'money'

class MoneyTest < Test::Unit::TestCase
  
  def setup
    
    @can1  = Money.ca_dollar(100)
    @can2  = Money.ca_dollar(200)
    @can3  = Money.ca_dollar(300)
    @us1   = Money.us_dollar(100)
    
    Money.bank = NoExchangeBank.new
    Money.default_currency = "USD"
    Money.default_currency_unit = "$"
  end
  
  def test_sanity

    assert_equal @can1, @can1
    assert_equal true, @can1 < @can2
    assert_equal true, @can3 > @can2
    assert_equal [@can1, @can2, @can3], [@can1, @can2, @can3]
    assert_equal [@can1, @can2, @can3], [@can3, @can2, @can1].sort
    assert_not_equal [@can1, @can2, @can3], [@can3, @can2, @can1]
    assert_equal [@can1], [@can1, @can2, @can3] & [@can1]

    assert_equal [@can1, @can2], [@can1] | [@can2]

    
    assert_equal @can3, @can1 + @can2
    assert_equal @can1, @can2 - @can1
    
    assert_equal Money.ca_dollar(500), Money.ca_dollar(10) + Money.ca_dollar(90) + Money.ca_dollar(500) - Money.ca_dollar(100)
      
  end
  
  def test_default_currency
    
    assert_equal Money.new(100).currency, "USD"
    Money.default_currency = "CAD"
    assert_equal Money.new(100).currency, "CAD"
  end
  
  def test_default_exchange   
    assert_raise(Money::MoneyError) do
      Money.us_dollar(100).exchange_to("CAD")
    end   
  end
  
  def test_zero
    assert_equal true, Money.empty.zero?
    assert_equal false, Money.ca_dollar(1).zero?
    assert_equal false, Money.ca_dollar(-1).zero?
  end
  
  def test_real_exchange   
    Money.bank = VariableExchangeBank.new
    Money.bank.add_rate("USD", "CAD", 1.24515)
    Money.bank.add_rate("CAD", "USD", 0.803115)
    assert_equal Money.us_dollar(100).exchange_to("CAD"), Money.ca_dollar(124)
    assert_equal Money.ca_dollar(100).exchange_to("USD"), Money.us_dollar(80)
  end
    
  def test_multiply    
    assert_equal Money.ca_dollar(5500), Money.ca_dollar(100) * 55    
    assert_equal Money.ca_dollar(150), Money.ca_dollar(100) * 1.50
    assert_equal Money.ca_dollar(50), Money.ca_dollar(100) * 0.50
  end

  def test_divide
    assert_equal Money.ca_dollar(100), Money.ca_dollar(5500) / 55    
    assert_equal Money.ca_dollar(100), Money.ca_dollar(200) / 2    
  end

  def test_divide_by_float
    assert_equal Money.ca_dollar(55000), Money.ca_dollar(55) / 0.001    
    assert_equal Money.ca_dollar(275), Money.ca_dollar(55) / 0.2
    # Round down (55 / 0.3 = 183.3333)
    assert_equal Money.ca_dollar(183), Money.ca_dollar(55) / 0.3
    # Round up (55 / 0.4 = 138.5)
    assert_equal Money.ca_dollar(138), Money.ca_dollar(55) / 0.4
  end
  
  def test_empty_can_exchange_currency
    assert_equal Money.ca_dollar(100), Money.empty('USD') + Money.ca_dollar(100)
    assert_equal Money.ca_dollar(100), Money.ca_dollar(100) + Money.empty('USD')
    
    assert_equal Money.ca_dollar(-100), Money.empty('USD') - Money.ca_dollar(-100)
    assert_equal Money.ca_dollar(-100), Money.ca_dollar(-100) - Money.empty('USD')
  end
  
  def test_to_s
    assert_equal "1.00", @can1.to_s
    assert_equal "390.50", Money.ca_dollar(39050).to_s
  end
  
  def test_substract_from_zero
   assert_equal -12.to_money, Money.empty - (12.to_money)
  end
  
  
  def test_formatting

    assert_equal "$0.00", Money.ca_dollar(0).format
    assert_equal "$1.00", @can1.format 
    assert_equal "$1.00 CAD", @can1.format(:with_currency)

    assert_equal "$1", @can1.format(:no_pence)
    assert_equal "$5", Money.ca_dollar(570).format(:no_pence)

    assert_equal "$5 CAD", Money.ca_dollar(570).format([:no_pence, :with_currency])
    assert_equal "$5 CAD", Money.ca_dollar(570).format(:no_pence, :with_currency)
    assert_equal "$390", Money.ca_dollar(39000).format(:no_pence)

    assert_equal "$5.70 <span class=\"currency\">CAD</span>", Money.ca_dollar(570).format([:html, :with_currency])
    
  end
  
  def test_negative
    assert_equal true, Money.new(-1).negative?
    assert_equal false, Money.new(0).negative?
    assert_equal false, Money.new(1).negative?
  end
  
end