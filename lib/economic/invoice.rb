require 'economic/entity'

module Economic
  class Invoice < Entity
    has_properties :number,
                   :debtor_handle,
                   :project_handle,
                   :debtor_name,
                   :debtor_address,
                   :debtor_postal_code,
                   :debtor_city,
                   :debtor_country,
                   :debtor_ean,
                   :public_entry_number,
                   :attention_handle,
                   :your_reference_handle,
                   :our_reference_handle,
                   :our_reference2_handle,
                   :term_of_payment_handle,
                   :currency_handle,
                   :is_vat_included,
                   :layout_handle,
                   :delivery_location_handle,
                   :delivery_address,
                   :delivery_postal_code,
                   :delivery_city,
                   :delivery_country,
                   :terms_of_delivery,
                   :delivery_date,
                   :date,
                   :due_date,
                   :heading,
                   :text_line1,
                   :text_line2,
                   :other_reference,
                   :order_number,
                   :net_amount,
                   :vat_amount,
                   :gross_amount,
                   :remainder,
                   :remainder_default_currency,
                   :rounding_amount,
                   :debtor_county,
                   :delivery_county,
                   :net_amount_default_currency,
                   :deduction_amount

    def attention
      return nil if attention_handle.nil?
      @attention ||= session.contacts.find(attention_handle)
    end

    def attention=(contact)
      self.attention_handle = contact.handle
      @attention = contact
    end

    def attention_handle=(handle)
      @attention = nil unless handle == @attention_handle
      @attention_handle = handle
    end

    def debtor
      return nil if debtor_handle.nil?
      @debtor ||= session.debtors.find(debtor_handle)
    end

    def debtor=(debtor)
      self.debtor_handle = debtor.handle
      @debtor = debtor
    end

    def debtor_handle=(handle)
      @debtor = nil unless handle == @debtor_handle
      @debtor_handle = handle
    end

    def remainder
      request(:get_remainder, {
        "invoiceHandle" => handle.to_hash
      })
    end

    # Returns the PDF version of Invoice as a String.
    #
    # To get it as a file you can do:
    #
    #   File.open("invoice.pdf", 'wb') do |file|
    #     file << invoice.pdf
    #   end
    def pdf
      response = request(:get_pdf, {
        "invoiceHandle" => handle.to_hash
      })

      Base64.decode64(response)
    end
  end
end
