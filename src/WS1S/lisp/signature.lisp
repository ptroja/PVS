(in-package :pvs)

(defvar *ws1s-signature* nil)

;; Signature

(def-pvs-term fset-of-nats "finite_set[nat]" "record_prelude_example" :nt type-expr)

(def-pvs-term empty-fset-of-nats "emptyset[nat]" "record_prelude_example"
                                 :expected "finite_set[nat]")

(def-pvs-term add-to-fset "add[nat]" "record_prelude_example"
                          :expected "[nat, finite_set[nat] -> finite_set[nat]]")


(def-pvs-term the1      "the[nat]" "naturalnumbers")
(def-pvs-term the2      "the[finite_set[nat]]" "record_prelude_example")
(def-pvs-term minus1 "-" "naturalnumbers" :expected "[nat, nat -> nat]")
(def-pvs-term plus1  "+" "naturalnumbers" :expected "[nat, nat -> nat]")

(def-pvs-term add-operator "add" "record_prelude_example"
                           :expected "[nat, set[nat] -> set[nat]]")
(def-pvs-term remove-operator "remove" "record_prelude_example"
                           :expected "[nat, set[nat] -> set[nat]]")
(def-pvs-term singleton-operator "singleton" "record_prelude_example"
                           :expected "[nat -> set[nat]]")
(def-pvs-term union-operator    "union" "record_prelude_example"
                                    :expected "[set[nat], set[nat] -> set[nat]]")
(def-pvs-term intersection-operator "intersection" "record_prelude_example"
                                    :expected "[set[nat], set[nat] -> set[nat]]")
(def-pvs-term set-difference-operator "difference" "record_prelude_example"
                                    :expected "[set[nat], set[nat] -> set[nat]]")
(def-pvs-term emptyset-operator "emptyset" "record_prelude_example"
                                    :expected "set[nat]")

(defun ws1s-types ()
  (list *boolean*
	*naturalnumber*
	(fset-of-nats)))
  
(defun ws1s-type? (type)
  (member type (ws1s-types) :test #'tc-eq))
  
(defun 0th-order? (expr)
  (subtype-of? (type expr) *boolean*))

(defun 1st-order? (expr)
  (assert (typep expr 'expr))
  (or (subtype-of? (type expr) *naturalnumber*)
      (and (number-expr? expr)
	   (integerp (number expr))
	   (>= (number expr) 0))
      (and (application? expr)
	   (or (tc-eq (operator expr) (plus1))
	       (tc-eq (operator expr) (minus1))))
      (some #'subtype-of-nat? (judgement-types+ expr))))

(defun subtype-of-nat? (type)
  (subtype-of? type *naturalnumber*))
  
(defun 2nd-order? (expr)
  (or (subtype-of? (type expr) (fset-of-nats))
      (finite-set-of-nat? expr)
      (tc-eq expr (emptyset-operator))
      (and (application? expr)
	   (let ((op (operator expr))
		 (args (arguments expr)))
	     (or (and (tc-eq op (singleton-operator))
		      (1st-order? (first args)))
		 (and (or (tc-eq op (add-operator))
			  (tc-eq op (remove-operator)))
		      (1st-order? (first args))
		      (2nd-order? (second args))))))))
 
(defun level (expr)
  (cond ((boolean? expr) 0)
	((1st-order? expr) 1)
	((2nd-order? expr) 2)))

;; Recognizers

(defun var? (expr) 
  (and (name-expr? expr)
    ;   (member (kind expr) '(variable constant))
    ;   (typep (declaration expr) '(and const-decl (not def-decl)))
       (not (def-axiom (declaration expr)))))

(defun var0? (expr) (and (var? expr) (boolean? expr)))
(defun var1? (expr) (and (var? expr) (1st-order? expr)))
(defun var2? (expr) (and (var? expr) (2nd-order? expr)))
