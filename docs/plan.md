# Plan
In this markdown file, you should plan what you are going to build

## Question
What is the core question you are trying to answer?

## Scope (v1)
What exactly are you trying to solve in this version?
What are you not solving?

## Inputs
What are the minimum set of sources you need to answer the in-scope questions?

### Required
State your required sources here, and their relevant columns

### Optional (v2+ enrichment)
State any optional sources here that could be used in further iterations

## Output models
Outline the final `marts` type models that you are working towards.

### 1) `fct_<example_1>`
**Grain:** one row per __.

**Contains:**
- List the columns you want it to have

### 2) `agg_<example_2>`
**Grain:** one row per __.

**Contains:**
- List the columns you want it to have

## Definitions & logic notes
Is there any important business logic or context that you need to define up front?

## Acceptance criteria (definition of done)
List the criteria that, when achieved, will form your definition of done

## Assumptions & edge cases
- List any assumptions or edge cases to be aware of