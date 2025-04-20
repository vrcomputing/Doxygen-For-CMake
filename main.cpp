/// @file

#include <iostream>
#include <cstdlib>

/// @brief Example enumeration
enum Enumeration
{
	A, ///< Description for A
	B, ///< Description for B
	C  ///< Description for C
};

// simulate Qt's macros

/// Mimic Qt's Q_PROPERTY macro
#define Q_PROPERTY(...)
/// Mimic Qt's signals macro
#define signals public
/// Mimic Qt's slots macro
#define slots

/// @brief Example Documentation
/// @nosubgrouping
class Example
{
    /// @name Setters
    /// @{
    /// @}
    /// @name Getters
    /// @{
    /// @}

	/// @brief Propert documentation
	Q_PROPERTY(bool example READ example WRITE setExample NOTIFY exampleChanged)
public:
	/// @todo
	Example() = default;

	/// @cond DISABLE_DOXYGEN
	~Example() = default;
	/// @endcond

	/// @returns Returns a new QWidget
	/// @ownercaller
	int* create(){ return new int; }

	/// @getter{example}
    bool example() const { return true; }

	/// @setter example
	/// @param value The property's new value
	void setExample(bool value){}

signals:
	/// @signal example
	void exampleChanged(bool);

private slots:
	/// @todo
	void showMessage();
};

/// @name Setters
/// @{
/// @fn void Example::setExample(bool)
/// @}
/// @name Getters
/// @{
/// @fn bool Example::example()
/// @}

/// @brief Application's entry function
/// @returns EXIT_SUCCESS on success or EXIT_FAILURE otherwise
int main()
{
    std::cout << "Hello World";
    return EXIT_SUCCESS;
}