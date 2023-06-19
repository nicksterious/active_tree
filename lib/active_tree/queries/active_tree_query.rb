class ActiveTree::Query
    def valid?(attribute, value)
        return false if !attribute.is_a? Symbol
        return false if value.nil? || value.empty? || !value.present?
        return valse if [ "", [], ["0"], [ 0 ], "all", "any" ].include? value
        return true
    end # valid?

end
