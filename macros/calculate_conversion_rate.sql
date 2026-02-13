{% macro calculate_conversion_rate(numerator, denominator, decimal_places=2) %}
    ROUND(
        (CAST({{ numerator }} AS NUMERIC) / NULLIF({{ denominator }}, 0)) * 100,
        {{ decimal_places }}
    )
{% endmacro %}
